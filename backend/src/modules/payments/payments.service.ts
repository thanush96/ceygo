import {
  Injectable,
  NotFoundException,
  BadRequestException,
} from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository, EntityManager } from 'typeorm';
import { Payment } from './entities/payment.entity';
import { Booking } from '../bookings/entities/booking.entity';
import { Wallet } from '../users/entities/wallet.entity';
import { WalletTransaction, TransactionType, TransactionStatus } from '../users/entities/wallet-transaction.entity';
import { ProcessPaymentDto } from './dto/process-payment.dto';
import { PaymentStatus } from '../../../common/enums/payment-status.enum';
import { PaymentMethod } from '../../../common/enums/payment-method.enum';
import { ConfigService } from '@nestjs/config';
import { BnplService } from './services/bnpl.service';
import { EmiService } from './services/emi.service';
import { CommissionService } from '../revenue/services/commission.service';
import axios from 'axios';

@Injectable()
export class PaymentsService {
  constructor(
    @InjectRepository(Payment)
    private paymentRepository: Repository<Payment>,
    @InjectRepository(Booking)
    private bookingRepository: Repository<Booking>,
    @InjectRepository(Wallet)
    private walletRepository: Repository<Wallet>,
    @InjectRepository(WalletTransaction)
    private walletTransactionRepository: Repository<WalletTransaction>,
    private configService: ConfigService,
    private bnplService: BnplService,
    private emiService: EmiService,
    private commissionService: CommissionService,
  ) {}

  async processPayment(userId: string, dto: ProcessPaymentDto): Promise<Payment> {
    // Use transaction to ensure atomicity
    return await this.paymentRepository.manager.transaction(async (manager) => {
      const booking = await manager.findOne(Booking, {
        where: { id: dto.bookingId, userId },
        relations: ['payment'],
      });

      if (!booking) {
        throw new NotFoundException('Booking not found');
      }

      if (booking.payment && booking.payment.status === PaymentStatus.COMPLETED) {
        throw new BadRequestException('Payment already processed');
      }

      let payment: Payment;
      if (booking.payment) {
        payment = booking.payment;
      } else {
        payment = manager.create(Payment, {
          bookingId: dto.bookingId,
          amount: booking.totalPrice,
          method: dto.method,
          status: PaymentStatus.PROCESSING,
        });
        payment = await manager.save(Payment, payment);
      }

      try {
        switch (dto.method) {
          case PaymentMethod.WALLET:
            await this.processWalletPaymentInTransaction(userId, payment, booking, manager);
            break;
          case PaymentMethod.PAYHERE:
            await this.processPayHerePayment(payment, booking);
            break;
          case PaymentMethod.MINTPAY:
          case PaymentMethod.KOKO:
            await this.processMintpayPayment(payment, booking, dto.method);
            break;
          case PaymentMethod.CARD:
            await this.processCardPayment(payment, booking, dto.cardToken);
            break;
          case PaymentMethod.BNPL:
            // BNPL is handled separately via initiateBnpl
            throw new BadRequestException('Use /payments/bnpl/initiate endpoint for BNPL');
          case PaymentMethod.EMI:
            // EMI is handled separately via initiateEmi
            throw new BadRequestException('Use /payments/emi/initiate endpoint for EMI');
          default:
            throw new BadRequestException('Invalid payment method');
        }

        payment.status = PaymentStatus.COMPLETED;
        await manager.save(Payment, payment);

        // Confirm booking
        booking.status = 'confirmed' as any;
        await manager.save(Booking, booking);

        // Create revenue records
        try {
          await this.commissionService.createRevenueRecords(
            booking.id,
            payment.id,
            manager,
          );
        } catch (error) {
          console.error('Failed to create revenue records:', error);
          // Don't fail the payment if revenue record creation fails
        }

        return payment;
      } catch (error) {
        payment.status = PaymentStatus.FAILED;
        payment.failureReason = error.message;
        await manager.save(Payment, payment);
        throw error;
      }
    });
  }

  private async processWalletPaymentInTransaction(
    userId: string,
    payment: Payment,
    booking: Booking,
    manager: EntityManager,
  ): Promise<void> {
    const wallet = await manager.findOne(Wallet, {
      where: { user: { id: userId } },
    });

    if (!wallet || wallet.balance < payment.amount) {
      throw new BadRequestException('Insufficient wallet balance');
    }

    const balanceBefore = wallet.balance;
    wallet.balance -= payment.amount;
    wallet.totalSpent += payment.amount;
    await manager.save(Wallet, wallet);

    // Create transaction record
    const transaction = manager.create(WalletTransaction, {
      wallet,
      amount: payment.amount,
      type: TransactionType.DEBIT,
      status: TransactionStatus.COMPLETED,
      description: `Payment for booking ${booking.id}`,
      reference: payment.id,
      bookingId: booking.id,
      balanceBefore,
      balanceAfter: wallet.balance,
    });
    await manager.save(WalletTransaction, transaction);

    payment.transactionId = transaction.id;
    payment.gatewayResponse = JSON.stringify({ method: 'wallet', transactionId: transaction.id });
  }

  private async processWalletPayment(
    userId: string,
    payment: Payment,
    booking: Booking,
  ): Promise<void> {
    const wallet = await this.walletRepository.findOne({
      where: { user: { id: userId } },
    });

    if (!wallet || wallet.balance < payment.amount) {
      throw new BadRequestException('Insufficient wallet balance');
    }

    const balanceBefore = wallet.balance;
    wallet.balance -= payment.amount;
    wallet.totalSpent += payment.amount;
    await this.walletRepository.save(wallet);

    // Create transaction record
    const transaction = this.walletTransactionRepository.create({
      wallet,
      amount: payment.amount,
      type: TransactionType.DEBIT,
      status: TransactionStatus.COMPLETED,
      description: `Payment for booking ${booking.id}`,
      reference: payment.id,
      bookingId: booking.id,
      balanceBefore,
      balanceAfter: wallet.balance,
    });
    await this.walletTransactionRepository.save(transaction);

    payment.transactionId = transaction.id;
    payment.gatewayResponse = JSON.stringify({ method: 'wallet', transactionId: transaction.id });
  }

  private async processPayHerePayment(
    payment: Payment,
    booking: Booking,
  ): Promise<void> {
    // TODO: Integrate with PayHere API
    const merchantId = this.configService.get<string>('PAYHERE_MERCHANT_ID');
    const secret = this.configService.get<string>('PAYHERE_SECRET');
    const sandbox = this.configService.get<string>('PAYHERE_SANDBOX') === 'true';

    // Mock implementation - replace with actual PayHere integration
    const gatewayTransactionId = `PH_${Date.now()}`;
    payment.gatewayTransactionId = gatewayTransactionId;
    payment.gatewayResponse = JSON.stringify({
      merchantId,
      transactionId: gatewayTransactionId,
      status: 'success',
    });
  }

  private async processMintpayPayment(
    payment: Payment,
    booking: Booking,
    method: PaymentMethod,
  ): Promise<void> {
    // TODO: Integrate with Mintpay/Koko API
    const apiKey = this.configService.get<string>('MINTPAY_API_KEY');
    const secret = this.configService.get<string>('MINTPAY_SECRET');
    const sandbox = this.configService.get<string>('MINTPAY_SANDBOX') === 'true';

    // Mock implementation - replace with actual Mintpay/Koko integration
    const gatewayTransactionId = `${method.toUpperCase()}_${Date.now()}`;
    payment.gatewayTransactionId = gatewayTransactionId;
    payment.gatewayResponse = JSON.stringify({
      apiKey,
      transactionId: gatewayTransactionId,
      status: 'success',
    });
  }

  private async processCardPayment(
    payment: Payment,
    booking: Booking,
    cardToken?: string,
  ): Promise<void> {
    // TODO: Integrate with card payment gateway (Stripe, etc.)
    if (!cardToken) {
      throw new BadRequestException('Card token is required for card payments');
    }

    // Mock implementation - replace with actual card payment integration
    const gatewayTransactionId = `CARD_${Date.now()}`;
    payment.gatewayTransactionId = gatewayTransactionId;
    payment.gatewayResponse = JSON.stringify({
      cardToken,
      transactionId: gatewayTransactionId,
      status: 'success',
    });
  }

  async findOne(paymentId: string): Promise<Payment> {
    const payment = await this.paymentRepository.findOne({
      where: { id: paymentId },
      relations: ['booking', 'bnplPlans', 'emiPlans'],
    });

    if (!payment) {
      throw new NotFoundException('Payment not found');
    }

    return payment;
  }

  async refund(paymentId: string, amount?: number): Promise<Payment> {
    const payment = await this.paymentRepository.findOne({
      where: { id: paymentId },
      relations: ['booking'],
    });

    if (!payment) {
      throw new NotFoundException('Payment not found');
    }

    if (payment.status !== PaymentStatus.COMPLETED) {
      throw new BadRequestException('Only completed payments can be refunded');
    }

    const refundAmount = amount || payment.amount;

    // Process refund based on payment method
    if (payment.method === PaymentMethod.WALLET) {
      // Refund to wallet
      const booking = await this.bookingRepository.findOne({
        where: { id: payment.bookingId },
        relations: ['user', 'user.wallet'],
      });

      if (booking && booking.user.wallet) {
        const wallet = booking.user.wallet;
        wallet.balance += refundAmount;
        await this.walletRepository.save(wallet);

        const transaction = this.walletTransactionRepository.create({
          wallet,
          amount: refundAmount,
          type: TransactionType.CREDIT,
          status: TransactionStatus.COMPLETED,
          description: `Refund for payment ${payment.id}`,
          reference: payment.id,
          bookingId: payment.bookingId,
          balanceBefore: wallet.balance - refundAmount,
          balanceAfter: wallet.balance,
        });
        await this.walletTransactionRepository.save(transaction);
      }
    } else {
      // Refund through payment gateway
      // TODO: Implement gateway refund
    }

    payment.status = PaymentStatus.REFUNDED;
    payment.refundAmount = refundAmount;
    payment.refundedAt = new Date();
    payment.refundTransactionId = `REF_${Date.now()}`;

    return this.paymentRepository.save(payment);
  }

  /**
   * Process BNPL payment (first installment)
   */
  async processBnplPayment(
    userId: string,
    bookingId: string,
    installmentCount: number,
    provider?: string,
  ): Promise<Payment> {
    return await this.paymentRepository.manager.transaction(async (manager) => {
      const booking = await manager.findOne(Booking, {
        where: { id: bookingId, userId },
        relations: ['payment', 'vehicle', 'vehicle.driver'],
      });

      if (!booking) {
        throw new NotFoundException('Booking not found');
      }

      if (booking.payment && booking.payment.status === PaymentStatus.COMPLETED) {
        throw new BadRequestException('Payment already processed');
      }

      // Check BNPL eligibility
      const eligibility = await this.bnplService.checkEligibility(
        userId,
        booking.totalPrice,
      );

      if (!eligibility.eligible) {
        throw new BadRequestException(eligibility.reason || 'Not eligible for BNPL');
      }

      // Create payment record
      let payment: Payment;
      if (booking.payment) {
        payment = booking.payment;
      } else {
        payment = manager.create(Payment, {
          bookingId,
          amount: booking.totalPrice,
          method: PaymentMethod.BNPL,
          status: PaymentStatus.PROCESSING,
          isBnpl: true,
        });
        payment = await manager.save(Payment, payment);
      }

      try {
        // Create BNPL plan
        const bnplPlan = await this.bnplService.createPlan(
          {
            paymentId: payment.id,
            bookingId,
            installmentCount,
            provider,
          },
          manager,
        );

        payment.bnplPlanId = bnplPlan.id;
        payment.status = PaymentStatus.COMPLETED;
        await manager.save(Payment, payment);

        // Confirm booking
        booking.status = 'confirmed' as any;
        await manager.save(Booking, booking);

        // Create revenue records
        try {
          await this.commissionService.createRevenueRecords(
            booking.id,
            payment.id,
            manager,
          );
        } catch (error) {
          console.error('Failed to create revenue records:', error);
        }

        return payment;
      } catch (error) {
        payment.status = PaymentStatus.FAILED;
        payment.failureReason = error.message;
        await manager.save(Payment, payment);
        throw error;
      }
    });
  }

  /**
   * Process EMI payment
   */
  async processEmiPayment(
    userId: string,
    bookingId: string,
    bankName: string,
    tenureMonths: number,
  ): Promise<Payment> {
    return await this.paymentRepository.manager.transaction(async (manager) => {
      const booking = await manager.findOne(Booking, {
        where: { id: bookingId, userId },
        relations: ['payment', 'vehicle', 'vehicle.driver'],
      });

      if (!booking) {
        throw new NotFoundException('Booking not found');
      }

      if (booking.payment && booking.payment.status === PaymentStatus.COMPLETED) {
        throw new BadRequestException('Payment already processed');
      }

      // Check EMI eligibility
      const eligibility = await this.emiService.checkEligibility(
        userId,
        booking.totalPrice,
      );

      if (!eligibility.eligible) {
        throw new BadRequestException(eligibility.reason || 'Not eligible for EMI');
      }

      // Create payment record
      let payment: Payment;
      if (booking.payment) {
        payment = booking.payment;
      } else {
        payment = manager.create(Payment, {
          bookingId,
          amount: booking.totalPrice,
          method: PaymentMethod.EMI,
          status: PaymentStatus.PROCESSING,
          isEmi: true,
        });
        payment = await manager.save(Payment, payment);
      }

      try {
        // Create EMI plan
        const emiPlan = await this.emiService.createPlan(
          {
            paymentId: payment.id,
            bookingId,
            bankName,
            tenureMonths,
          },
          manager,
        );

        payment.emiPlanId = emiPlan.id;
        payment.status = PaymentStatus.COMPLETED;
        await manager.save(Payment, payment);

        // Confirm booking
        booking.status = 'confirmed' as any;
        await manager.save(Booking, booking);

        // Create revenue records
        try {
          await this.commissionService.createRevenueRecords(
            booking.id,
            payment.id,
            manager,
          );
        } catch (error) {
          console.error('Failed to create revenue records:', error);
        }

        return payment;
      } catch (error) {
        payment.status = PaymentStatus.FAILED;
        payment.failureReason = error.message;
        await manager.save(Payment, payment);
        throw error;
      }
    });
  }
}
