import {
  Injectable,
  NotFoundException,
  BadRequestException,
} from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository, EntityManager } from 'typeorm';
import { Subscription, SubscriptionStatus } from '../entities/subscription.entity';
import { SubscriptionPayment } from '../entities/subscription-payment.entity';
import { User } from '../../users/entities/user.entity';
import { ConfigService } from '@nestjs/config';
import { addMonths, isAfter } from 'date-fns';

export enum SubscriptionPlanType {
  BASIC = 'basic',
  PREMIUM = 'premium',
  ENTERPRISE = 'enterprise',
}

export interface SubscriptionPlan {
  type: SubscriptionPlanType;
  name: string;
  pricePerMonth: number;
  discountPercentage: number;
  features: string[];
}

@Injectable()
export class SubscriptionsService {
  constructor(
    @InjectRepository(Subscription)
    private subscriptionRepository: Repository<Subscription>,
    @InjectRepository(SubscriptionPayment)
    private subscriptionPaymentRepository: Repository<SubscriptionPayment>,
    @InjectRepository(User)
    private userRepository: Repository<User>,
    private configService: ConfigService,
  ) {}

  /**
   * Get available subscription plans
   */
  getAvailablePlans(): SubscriptionPlan[] {
    return [
      {
        type: SubscriptionPlanType.BASIC,
        name: 'Basic Plan',
        pricePerMonth: 500,
        discountPercentage: 0,
        features: ['5% discount on bookings', 'Priority support'],
      },
      {
        type: SubscriptionPlanType.PREMIUM,
        name: 'Premium Plan',
        pricePerMonth: 1500,
        discountPercentage: 3,
        features: [
          '10% discount on bookings',
          'Priority support',
          'Free cancellations',
          'Exclusive vehicles',
        ],
      },
      {
        type: SubscriptionPlanType.ENTERPRISE,
        name: 'Enterprise Plan',
        pricePerMonth: 5000,
        discountPercentage: 5,
        features: [
          '15% discount on bookings',
          '24/7 priority support',
          'Free cancellations',
          'Exclusive vehicles',
          'Dedicated account manager',
        ],
      },
    ];
  }

  /**
   * Create a subscription
   */
  async createSubscription(
    userId: string,
    planType: SubscriptionPlanType,
    paymentMethod: string,
    autoRenew: boolean = true,
    manager?: EntityManager,
  ): Promise<Subscription> {
    const userRepo = manager
      ? manager.getRepository(User)
      : this.userRepository;
    const subRepo = manager
      ? manager.getRepository(Subscription)
      : this.subscriptionRepository;

    const user = await userRepo.findOne({ where: { id: userId } });
    if (!user) {
      throw new NotFoundException('User not found');
    }

    // Check for existing active subscription
    const existingSubscription = await subRepo.findOne({
      where: {
        user: { id: userId },
        status: SubscriptionStatus.ACTIVE,
      },
    });

    if (existingSubscription) {
      throw new BadRequestException('User already has an active subscription');
    }

    const plans = this.getAvailablePlans();
    const selectedPlan = plans.find((p) => p.type === planType);

    if (!selectedPlan) {
      throw new BadRequestException('Invalid subscription plan');
    }

    const startDate = new Date();
    const endDate = addMonths(startDate, 1); // Monthly subscription

    const subscription = subRepo.create({
      userId,
      planType,
      planName: selectedPlan.name,
      pricePerMonth: selectedPlan.pricePerMonth,
      discountPercentage: selectedPlan.discountPercentage,
      status: SubscriptionStatus.ACTIVE,
      startDate,
      endDate,
      autoRenew,
      paymentMethod,
    });

    return subRepo.save(subscription);
  }

  /**
   * Get user's active subscription
   */
  async getUserSubscription(userId: string): Promise<Subscription | null> {
    return this.subscriptionRepository.findOne({
      where: {
        user: { id: userId },
        status: SubscriptionStatus.ACTIVE,
      },
      order: { createdAt: 'DESC' },
    });
  }

  /**
   * Renew subscription
   */
  async renewSubscription(
    subscriptionId: string,
    manager?: EntityManager,
  ): Promise<Subscription> {
    const subRepo = manager
      ? manager.getRepository(Subscription)
      : this.subscriptionRepository;

    const subscription = await subRepo.findOne({
      where: { id: subscriptionId },
    });

    if (!subscription) {
      throw new NotFoundException('Subscription not found');
    }

    if (subscription.status !== SubscriptionStatus.ACTIVE) {
      throw new BadRequestException('Subscription is not active');
    }

    // Extend subscription by 1 month
    const newEndDate = addMonths(subscription.endDate || new Date(), 1);
    subscription.endDate = newEndDate;
    subscription.status = SubscriptionStatus.ACTIVE;

    return subRepo.save(subscription);
  }

  /**
   * Cancel subscription
   */
  async cancelSubscription(subscriptionId: string): Promise<Subscription> {
    const subscription = await this.subscriptionRepository.findOne({
      where: { id: subscriptionId },
    });

    if (!subscription) {
      throw new NotFoundException('Subscription not found');
    }

    subscription.status = SubscriptionStatus.CANCELLED;
    subscription.autoRenew = false;

    return this.subscriptionRepository.save(subscription);
  }

  /**
   * Process subscription payment
   */
  async processSubscriptionPayment(
    subscriptionId: string,
    paymentId: string,
    amount: number,
    manager?: EntityManager,
  ): Promise<SubscriptionPayment> {
    const subRepo = manager
      ? manager.getRepository(Subscription)
      : this.subscriptionRepository;
    const paymentRepo = manager
      ? manager.getRepository(SubscriptionPayment)
      : this.subscriptionPaymentRepository;

    const subscription = await subRepo.findOne({
      where: { id: subscriptionId },
    });

    if (!subscription) {
      throw new NotFoundException('Subscription not found');
    }

    const payment = paymentRepo.create({
      subscriptionId,
      amount,
      paymentDate: new Date(),
      status: 'completed' as any,
      paymentId: paymentId,
    });

    const savedPayment = await paymentRepo.save(payment);

    // Auto-renew if enabled
    if (subscription.autoRenew) {
      await this.renewSubscription(subscriptionId, manager);
    }

    return savedPayment;
  }

  /**
   * Check and expire subscriptions
   */
  async checkAndExpireSubscriptions(): Promise<void> {
    const today = new Date();

    await this.subscriptionRepository
      .createQueryBuilder()
      .update(Subscription)
      .set({ status: SubscriptionStatus.EXPIRED })
      .where('status = :status', { status: SubscriptionStatus.ACTIVE })
      .andWhere('endDate < :today', { today })
      .execute();
  }

  /**
   * Get subscription revenue
   */
  async getSubscriptionRevenue(
    startDate?: Date,
    endDate?: Date,
  ): Promise<{
    totalRevenue: number;
    activeSubscriptions: number;
    newSubscriptions: number;
    revenueByPlan: Record<string, number>;
  }> {
    const query = this.subscriptionPaymentRepository
      .createQueryBuilder('payment')
      .where('payment.status = :status', { status: 'completed' });

    if (startDate) {
      query.andWhere('payment.paymentDate >= :startDate', { startDate });
    }
    if (endDate) {
      query.andWhere('payment.paymentDate <= :endDate', { endDate });
    }

    const totalRevenueResult = await query
      .select('SUM(payment.amount)', 'total')
      .getRawOne();

    const totalRevenue = parseFloat(totalRevenueResult?.total || '0');

    const activeSubscriptions = await this.subscriptionRepository.count({
      where: { status: SubscriptionStatus.ACTIVE },
    });

    const newSubscriptionsQuery = this.subscriptionRepository
      .createQueryBuilder('sub')
      .where('sub.status = :status', { status: SubscriptionStatus.ACTIVE });

    if (startDate) {
      newSubscriptionsQuery.andWhere('sub.createdAt >= :startDate', {
        startDate,
      });
    }
    if (endDate) {
      newSubscriptionsQuery.andWhere('sub.createdAt <= :endDate', { endDate });
    }

    const newSubscriptions = await newSubscriptionsQuery.getCount();

    // Revenue by plan
    const revenueByPlanQuery = this.subscriptionPaymentRepository
      .createQueryBuilder('payment')
      .leftJoin('payment.subscription', 'sub')
      .where('payment.status = :status', { status: 'completed' });

    if (startDate) {
      revenueByPlanQuery.andWhere('payment.paymentDate >= :startDate', {
        startDate,
      });
    }
    if (endDate) {
      revenueByPlanQuery.andWhere('payment.paymentDate <= :endDate', {
        endDate,
      });
    }

    const revenueByPlanResults = await revenueByPlanQuery
      .select('sub.planType', 'planType')
      .addSelect('SUM(payment.amount)', 'total')
      .groupBy('sub.planType')
      .getRawMany();

    const revenueByPlan: Record<string, number> = {};
    revenueByPlanResults.forEach((result) => {
      revenueByPlan[result.planType] = parseFloat(result.total || '0');
    });

    return {
      totalRevenue,
      activeSubscriptions,
      newSubscriptions,
      revenueByPlan,
    };
  }
}
