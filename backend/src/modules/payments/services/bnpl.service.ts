import {
  Injectable,
  BadRequestException,
  NotFoundException,
} from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository, EntityManager, LessThanOrEqual } from 'typeorm';
import { BnplPlan, BnplPlanStatus } from '../entities/bnpl-plan.entity';
import { BnplInstallment, BnplInstallmentStatus } from '../entities/bnpl-installment.entity';
import { Payment } from '../entities/payment.entity';
import { Booking } from '../../bookings/entities/booking.entity';
import { ConfigService } from '@nestjs/config';
import { addDays, addMonths } from 'date-fns';

export interface BnplEligibilityCheck {
  eligible: boolean;
  reason?: string;
  maxAmount?: number;
  availablePlans?: BnplPlanOption[];
}

export interface BnplPlanOption {
  installmentCount: number;
  installmentAmount: number;
  interestRate: number;
  totalAmount: number;
}

export interface CreateBnplPlanDto {
  paymentId: string;
  bookingId: string;
  installmentCount: number;
  provider?: string;
}

@Injectable()
export class BnplService {
  constructor(
    @InjectRepository(BnplPlan)
    private bnplPlanRepository: Repository<BnplPlan>,
    @InjectRepository(BnplInstallment)
    private installmentRepository: Repository<BnplInstallment>,
    @InjectRepository(Payment)
    private paymentRepository: Repository<Payment>,
    @InjectRepository(Booking)
    private bookingRepository: Repository<Booking>,
    private configService: ConfigService,
  ) {}

  /**
   * Check if user is eligible for BNPL
   */
  async checkEligibility(
    userId: string,
    amount: number,
  ): Promise<BnplEligibilityCheck> {
    // Minimum amount for BNPL
    const minAmount = parseFloat(
      this.configService.get<string>('BNPL_MIN_AMOUNT', '5000'),
    );
    const maxAmount = parseFloat(
      this.configService.get<string>('BNPL_MAX_AMOUNT', '100000'),
    );

    if (amount < minAmount) {
      return {
        eligible: false,
        reason: `Minimum amount for BNPL is ${minAmount}`,
      };
    }

    if (amount > maxAmount) {
      return {
        eligible: false,
        reason: `Maximum amount for BNPL is ${maxAmount}`,
      };
    }

    // Check for existing active BNPL plans
    const activePlans = await this.bnplPlanRepository.count({
      where: {
        booking: { userId },
        status: BnplPlanStatus.ACTIVE,
      },
      relations: ['booking'],
    });

    const maxActivePlans = parseInt(
      this.configService.get<string>('BNPL_MAX_ACTIVE_PLANS', '2'),
    );

    if (activePlans >= maxActivePlans) {
      return {
        eligible: false,
        reason: 'Maximum active BNPL plans reached',
      };
    }

    // Available installment plans
    const availablePlans = this.getAvailablePlans(amount);

    return {
      eligible: true,
      maxAmount,
      availablePlans,
    };
  }

  /**
   * Get available BNPL plans for an amount
   */
  private getAvailablePlans(amount: number): BnplPlanOption[] {
    const plans: BnplPlanOption[] = [];
    const interestRate = parseFloat(
      this.configService.get<string>('BNPL_INTEREST_RATE', '0'),
    );

    // 3, 6, 9, 12 month plans
    const installments = [3, 6, 9, 12];

    for (const count of installments) {
      const installmentAmount = amount / count;
      const totalAmount = amount; // No interest for now, can be calculated

      plans.push({
        installmentCount: count,
        installmentAmount: Math.round(installmentAmount * 100) / 100,
        interestRate,
        totalAmount,
      });
    }

    return plans;
  }

  /**
   * Create a BNPL plan
   */
  async createPlan(
    dto: CreateBnplPlanDto,
    manager?: EntityManager,
  ): Promise<BnplPlan> {
    const paymentRepo = manager
      ? manager.getRepository(Payment)
      : this.paymentRepository;
    const bookingRepo = manager
      ? manager.getRepository(Booking)
      : this.bookingRepository;
    const planRepo = manager
      ? manager.getRepository(BnplPlan)
      : this.bnplPlanRepository;
    const installmentRepo = manager
      ? manager.getRepository(BnplInstallment)
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

    // Validate installment count
    const availablePlans = this.getAvailablePlans(payment.amount);
    const selectedPlan = availablePlans.find(
      (p) => p.installmentCount === dto.installmentCount,
    );

    if (!selectedPlan) {
      throw new BadRequestException('Invalid installment count');
    }

    // Calculate dates
    const firstPaymentDate = addDays(new Date(), 30); // First payment in 30 days
    const lastPaymentDate = addMonths(
      firstPaymentDate,
      dto.installmentCount - 1,
    );

    // Create BNPL plan
    const bnplPlan = planRepo.create({
      paymentId: dto.paymentId,
      bookingId: dto.bookingId,
      totalAmount: payment.amount,
      installmentCount: dto.installmentCount,
      installmentAmount: selectedPlan.installmentAmount,
      interestRate: selectedPlan.interestRate,
      firstPaymentDate,
      lastPaymentDate,
      provider: dto.provider || 'internal',
      status: BnplPlanStatus.ACTIVE,
    });

    const savedPlan = await planRepo.save(bnplPlan);

    // Create installments
    const installments: BnplInstallment[] = [];
    for (let i = 0; i < dto.installmentCount; i++) {
      const dueDate = addMonths(firstPaymentDate, i);
      const installment = installmentRepo.create({
        planId: savedPlan.id,
        installmentNumber: i + 1,
        amount: selectedPlan.installmentAmount,
        dueDate,
        status: BnplInstallmentStatus.PENDING,
      });
      installments.push(installment);
    }

    await installmentRepo.save(installments);

    // Update payment
    payment.isBnpl = true;
    payment.bnplPlanId = savedPlan.id;
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
  ): Promise<BnplInstallment> {
    const installmentRepo = manager
      ? manager.getRepository(BnplInstallment)
      : this.installmentRepository;
    const planRepo = manager
      ? manager.getRepository(BnplPlan)
      : this.bnplPlanRepository;
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

    if (installment.status === BnplInstallmentStatus.PAID) {
      throw new BadRequestException('Installment already paid');
    }

    // Mark as paid
    installment.status = BnplInstallmentStatus.PAID;
    installment.paidDate = new Date();
    installment.paymentId = paymentId;

    await installmentRepo.save(installment);

    // Check if all installments are paid
    const allInstallments = await installmentRepo.find({
      where: { planId: installment.planId },
    });

    const allPaid = allInstallments.every(
      (inst) => inst.status === BnplInstallmentStatus.PAID,
    );

    if (allPaid) {
      const plan = await planRepo.findOne({
        where: { id: installment.planId },
      });
      plan.status = BnplPlanStatus.COMPLETED;
      await planRepo.save(plan);
    }

    return installment;
  }

  /**
   * Get BNPL plan by ID
   */
  async getPlan(planId: string): Promise<BnplPlan> {
    const plan = await this.bnplPlanRepository.findOne({
      where: { id: planId },
      relations: ['installments', 'booking', 'payment'],
    });

    if (!plan) {
      throw new NotFoundException('BNPL plan not found');
    }

    return plan;
  }

  /**
   * Get user's BNPL plans
   */
  async getUserPlans(userId: string): Promise<BnplPlan[]> {
    return this.bnplPlanRepository.find({
      where: {
        booking: { userId },
      },
      relations: ['installments', 'booking'],
      order: { createdAt: 'DESC' },
    });
  }

  /**
   * Mark overdue installments
   */
  async markOverdueInstallments(): Promise<void> {
    const today = new Date();
    today.setHours(0, 0, 0, 0);

    await this.installmentRepository.update(
      {
        status: BnplInstallmentStatus.PENDING,
        dueDate: LessThanOrEqual(today),
      },
      {
        status: BnplInstallmentStatus.OVERDUE,
      },
    );
  }
}
