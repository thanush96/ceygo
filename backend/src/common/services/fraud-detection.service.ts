import { Injectable, Inject } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Booking } from '../../modules/bookings/entities/booking.entity';
import { Payment } from '../../modules/payments/entities/payment.entity';
import { CacheService } from './cache.service';

export interface FraudCheckResult {
  isFraud: boolean;
  riskScore: number;
  reasons: string[];
}

@Injectable()
export class FraudDetectionService {
  constructor(
    @InjectRepository(Booking)
    private bookingRepository: Repository<Booking>,
    @InjectRepository(Payment)
    private paymentRepository: Repository<Payment>,
    private cacheService: CacheService,
  ) {}

  /**
   * Check for booking conflicts and fraud patterns
   */
  async checkBookingFraud(
    userId: string,
    vehicleId: string,
    startDate: Date,
    endDate: Date,
    amount: number,
  ): Promise<FraudCheckResult> {
    const reasons: string[] = [];
    let riskScore = 0;

    // Check 1: Multiple bookings in short time
    const oneDayAgo = new Date(Date.now() - 24 * 60 * 60 * 1000);
    const recentBookings = await this.bookingRepository
      .createQueryBuilder('booking')
      .where('booking.userId = :userId', { userId })
      .andWhere('booking.createdAt >= :oneDayAgo', { oneDayAgo })
      .getCount();

    if (recentBookings > 5) {
      riskScore += 30;
      reasons.push('Too many bookings in last 24 hours');
    }

    // Check 2: High-value bookings
    const highValueThreshold = 50000;
    if (amount > highValueThreshold) {
      riskScore += 20;
      reasons.push('High-value booking detected');
    }

    // Check 3: Check for duplicate bookings
    const duplicateCheck = await this.bookingRepository.findOne({
      where: {
        userId,
        vehicleId,
        startDate,
        endDate,
      },
    });

    if (duplicateCheck) {
      riskScore += 50;
      reasons.push('Duplicate booking detected');
    }

    // Check 4: Check booking frequency from cache
    const bookingKey = `booking:frequency:${userId}`;
    const bookingCount = await this.cacheService.increment(bookingKey);
    await this.cacheService.expire(bookingKey, 3600); // 1 hour

    if (bookingCount > 10) {
      riskScore += 25;
      reasons.push('Excessive booking frequency');
    }

    // Check 5: Payment pattern analysis
    const sevenDaysAgo = new Date(Date.now() - 7 * 24 * 60 * 60 * 1000);
    const recentPayments = await this.paymentRepository
      .createQueryBuilder('payment')
      .leftJoin('payment.booking', 'booking')
      .where('booking.userId = :userId', { userId })
      .andWhere('payment.status = :status', { status: 'failed' })
      .andWhere('payment.createdAt >= :sevenDaysAgo', { sevenDaysAgo })
      .getCount();

    if (recentPayments > 3) {
      riskScore += 30;
      reasons.push('Multiple failed payments in recent history');
    }

    const isFraud = riskScore >= 70;

    return {
      isFraud,
      riskScore,
      reasons,
    };
  }

  /**
   * Check payment fraud
   */
  async checkPaymentFraud(
    userId: string,
    amount: number,
    paymentMethod: string,
  ): Promise<FraudCheckResult> {
    const reasons: string[] = [];
    let riskScore = 0;

    // Check 1: Unusual payment amount
    const avgPaymentKey = `payment:avg:${userId}`;
    const avgPayment = await this.cacheService.get<number>(avgPaymentKey);

    if (avgPayment && amount > avgPayment * 3) {
      riskScore += 25;
      reasons.push('Payment amount significantly higher than average');
    }

    // Check 2: Multiple payment attempts
    const paymentAttemptsKey = `payment:attempts:${userId}`;
    const attempts = await this.cacheService.increment(paymentAttemptsKey);
    await this.cacheService.expire(paymentAttemptsKey, 300); // 5 minutes

    if (attempts > 5) {
      riskScore += 35;
      reasons.push('Too many payment attempts in short time');
    }

    // Check 3: New payment method
    const paymentMethodKey = `payment:method:${userId}:${paymentMethod}`;
    const methodUsed = await this.cacheService.exists(paymentMethodKey);

    if (!methodUsed && paymentMethod !== 'wallet') {
      riskScore += 15;
      reasons.push('New payment method detected');
    }

    // Update average payment
    if (avgPayment) {
      const newAvg = (avgPayment + amount) / 2;
      await this.cacheService.set(avgPaymentKey, newAvg, 86400 * 30); // 30 days
    } else {
      await this.cacheService.set(avgPaymentKey, amount, 86400 * 30);
    }

    await this.cacheService.set(paymentMethodKey, true, 86400 * 30);

    const isFraud = riskScore >= 60;

    return {
      isFraud,
      riskScore,
      reasons,
    };
  }

  /**
   * Reset fraud detection cache for user (for testing/admin)
   */
  async resetUserCache(userId: string): Promise<void> {
    await this.cacheService.deletePattern(`*:${userId}*`);
  }
}
