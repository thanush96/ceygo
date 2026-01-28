import {
  Injectable,
  BadRequestException,
  NotFoundException,
} from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository, EntityManager } from 'typeorm';
import { EmiPlan, EmiPlanStatus } from '../entities/emi-plan.entity';
import { EmiInstallment, EmiInstallmentStatus } from '../entities/emi-installment.entity';
import { Payment } from '../entities/payment.entity';
import { Booking } from '../../bookings/entities/booking.entity';
import { ConfigService } from '@nestjs/config';
import { addMonths } from 'date-fns';

export interface EmiEligibilityCheck {
  eligible: boolean;
  reason?: string;
  availableBanks?: EmiBankOption[];
}

export interface EmiBankOption {
  bankName: string;
  interestRate: number;
  tenureMonths: number[];
  processingFee: number;
}

export interface EmiCalculation {
  principalAmount: number;
  interestRate: number;
  tenureMonths: number;
  emiAmount: number;
  totalAmount: number;
  totalInterest: number;
  breakdown: EmiInstallmentBreakdown[];
}

export interface EmiInstallmentBreakdown {
  installmentNumber: number;
  principalAmount: number;
  interestAmount: number;
  totalAmount: number;
  balance: number;
}

export interface CreateEmiPlanDto {
  paymentId: string;
  bookingId: string;
  bankName: string;
  tenureMonths: number;
}

@Injectable()
export class EmiService {
  constructor(
    @InjectRepository(EmiPlan)
    private emiPlanRepository: Repository<EmiPlan>,
    @InjectRepository(EmiInstallment)
    private installmentRepository: Repository<EmiInstallment>,
    @InjectRepository(Payment)
    private paymentRepository: Repository<Payment>,
    @InjectRepository(Booking)
    private bookingRepository: Repository<Booking>,
    private configService: ConfigService,
  ) {}

  /**
   * Check if user is eligible for EMI
   */
  async checkEligibility(
    userId: string,
    amount: number,
  ): Promise<EmiEligibilityCheck> {
    // Minimum amount for EMI
    const minAmount = parseFloat(
      this.configService.get<string>('EMI_MIN_AMOUNT', '10000'),
    );

    if (amount < minAmount) {
      return {
        eligible: false,
        reason: `Minimum amount for EMI is ${minAmount}`,
      };
    }

    const availableBanks = this.getAvailableBanks();

    return {
      eligible: true,
      availableBanks,
    };
  }

  /**
   * Get available banks for EMI
   */
  private getAvailableBanks(): EmiBankOption[] {
    // In production, this would come from a database or external API
    return [
      {
        bankName: 'Commercial Bank',
        interestRate: 12.0,
        tenureMonths: [3, 6, 9, 12, 18, 24],
        processingFee: 500,
      },
      {
        bankName: 'People\'s Bank',
        interestRate: 11.5,
        tenureMonths: [3, 6, 9, 12, 18, 24],
        processingFee: 500,
      },
      {
        bankName: 'Sampath Bank',
        interestRate: 12.5,
        tenureMonths: [3, 6, 9, 12, 18, 24],
        processingFee: 500,
      },
    ];
  }

  /**
   * Calculate EMI
   */
  calculateEmi(
    principalAmount: number,
    interestRate: number,
    tenureMonths: number,
  ): EmiCalculation {
    const monthlyRate = interestRate / 12 / 100;
    const emiAmount =
      (principalAmount *
        monthlyRate *
        Math.pow(1 + monthlyRate, tenureMonths)) /
      (Math.pow(1 + monthlyRate, tenureMonths) - 1);

    const totalAmount = emiAmount * tenureMonths;
    const totalInterest = totalAmount - principalAmount;

    // Generate breakdown
    const breakdown: EmiInstallmentBreakdown[] = [];
    let balance = principalAmount;

    for (let i = 1; i <= tenureMonths; i++) {
      const interestAmount = balance * monthlyRate;
      const principalPayment = emiAmount - interestAmount;
      balance -= principalPayment;

      breakdown.push({
        installmentNumber: i,
        principalAmount: Math.round(principalPayment * 100) / 100,
        interestAmount: Math.round(interestAmount * 100) / 100,
        totalAmount: Math.round(emiAmount * 100) / 100,
        balance: Math.round(balance * 100) / 100,
      });
    }

    return {
      principalAmount,
      interestRate,
      tenureMonths,
      emiAmount: Math.round(emiAmount * 100) / 100,
      totalAmount: Math.round(totalAmount * 100) / 100,
      totalInterest: Math.round(totalInterest * 100) / 100,
      breakdown,
    };
  }

  /**
   * Create an EMI plan
   */
  async createPlan(
    dto: CreateEmiPlanDto,
    manager?: EntityManager,
  ): Promise<EmiPlan> {
    const paymentRepo = manager
      ? manager.getRepository(Payment)
      : this.paymentRepository;
    const bookingRepo = manager
      ? manager.getRepository(Booking)
      : this.bookingRepository;
    const planRepo = manager
      ? manager.getRepository(EmiPlan)
      : this.emiPlanRepository;
    const installmentRepo = manager
      ? manager.getRepository(EmiInstallment)
      : this.installmentRepository;

    const payment = await paymentRepo.findOne({
      where: { id: dto.paymentId },
      relations: ['booking'],
    });

    if (!payment) {
      throw new NotFoundException('Payment not found');
    }

    const booking = await bookingRepo.findOne({
      where: { id: dto.bookingId },
    });

    if (!booking) {
      throw new NotFoundException('Booking not found');
    }

    // Get bank details
    const availableBanks = this.getAvailableBanks();
    const selectedBank = availableBanks.find(
      (bank) => bank.bankName === dto.bankName,
    );

    if (!selectedBank) {
      throw new BadRequestException('Invalid bank selected');
    }

    if (!selectedBank.tenureMonths.includes(dto.tenureMonths)) {
      throw new BadRequestException('Invalid tenure for selected bank');
    }

    // Calculate EMI
    const emiCalculation = this.calculateEmi(
      payment.amount,
      selectedBank.interestRate,
      dto.tenureMonths,
    );

    // Calculate dates
    const firstPaymentDate = addMonths(new Date(), 1); // First payment next month

    // Create EMI plan
    const emiPlan = planRepo.create({
      paymentId: dto.paymentId,
      bookingId: dto.bookingId,
      principalAmount: payment.amount,
      interestRate: selectedBank.interestRate,
      tenureMonths: dto.tenureMonths,
      emiAmount: emiCalculation.emiAmount,
      totalAmount: emiCalculation.totalAmount,
      firstPaymentDate,
      bankName: dto.bankName,
      status: EmiPlanStatus.ACTIVE,
    });

    const savedPlan = await planRepo.save(emiPlan);

    // Create installments
    const installments: EmiInstallment[] = [];
    for (let i = 0; i < dto.tenureMonths; i++) {
      const dueDate = addMonths(firstPaymentDate, i);
      const breakdown = emiCalculation.breakdown[i];

      const installment = installmentRepo.create({
        planId: savedPlan.id,
        installmentNumber: i + 1,
        principalAmount: breakdown.principalAmount,
        interestAmount: breakdown.interestAmount,
        totalAmount: breakdown.totalAmount,
        dueDate,
        status: EmiInstallmentStatus.PENDING,
      });
      installments.push(installment);
    }

    await installmentRepo.save(installments);

    // Update payment
    payment.isEmi = true;
    payment.emiPlanId = savedPlan.id;
    await paymentRepo.save(payment);

    return savedPlan;
  }

  /**
   * Process an installment payment
   */
  async processInstallment(
    installmentId: string,
    paymentId: string,
    manager?: EntityManager,
  ): Promise<EmiInstallment> {
    const installmentRepo = manager
      ? manager.getRepository(EmiInstallment)
      : this.installmentRepository;
    const planRepo = manager
      ? manager.getRepository(EmiPlan)
      : this.emiPlanRepository;
    const paymentRepo = manager
      ? manager.getRepository(Payment)
      : this.paymentRepository;

    const installment = await installmentRepo.findOne({
      where: { id: installmentId },
      relations: ['plan'],
    });

    if (!installment) {
      throw new NotFoundException('Installment not found');
    }

    if (installment.status === EmiInstallmentStatus.PAID) {
      throw new BadRequestException('Installment already paid');
    }

    // Mark as paid
    installment.status = EmiInstallmentStatus.PAID;
    installment.paidDate = new Date();
    installment.paymentId = paymentId;

    await installmentRepo.save(installment);

    // Check if all installments are paid
    const allInstallments = await installmentRepo.find({
      where: { planId: installment.planId },
    });

    const allPaid = allInstallments.every(
      (inst) => inst.status === EmiInstallmentStatus.PAID,
    );

    if (allPaid) {
      const plan = await planRepo.findOne({
        where: { id: installment.planId },
      });
      plan.status = EmiPlanStatus.COMPLETED;
      await planRepo.save(plan);
    }

    return installment;
  }

  /**
   * Get EMI plan by ID
   */
  async getPlan(planId: string): Promise<EmiPlan> {
    const plan = await this.emiPlanRepository.findOne({
      where: { id: planId },
      relations: ['installments', 'booking', 'payment'],
    });

    if (!plan) {
      throw new NotFoundException('EMI plan not found');
    }

    return plan;
  }

  /**
   * Get user's EMI plans
   */
  async getUserPlans(userId: string): Promise<EmiPlan[]> {
    return this.emiPlanRepository.find({
      where: {
        booking: { userId },
      },
      relations: ['installments', 'booking'],
      order: { createdAt: 'DESC' },
    });
  }
}
