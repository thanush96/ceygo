import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository, EntityManager } from 'typeorm';
import { RevenueRecord, RevenueType, RevenueStatus } from '../entities/revenue-record.entity';
import { Booking } from '../../bookings/entities/booking.entity';
import { Payment } from '../../payments/entities/payment.entity';
import { ConfigService } from '@nestjs/config';
import { PricingRulesService } from './pricing-rules.service';

@Injectable()
export class CommissionService {
  constructor(
    @InjectRepository(RevenueRecord)
    private revenueRepository: Repository<RevenueRecord>,
    @InjectRepository(Booking)
    private bookingRepository: Repository<Booking>,
    @InjectRepository(Payment)
    private paymentRepository: Repository<Payment>,
    private configService: ConfigService,
    private pricingRulesService: PricingRulesService,
  ) {}

  /**
   * Calculate commission for a booking
   */
  async calculateCommission(
    bookingId: string,
    totalPrice: number,
    driverId?: string,
    city?: string,
  ): Promise<{
    commission: number;
    platformFee: number;
    driverEarnings: number;
    commissionRate: number;
    platformFeeRate: number;
  }> {
    // Get base commission rate from config
    let commissionRate = parseFloat(
      this.configService.get<string>('COMMISSION_PERCENTAGE', '15'),
    );

    // Get platform fee rate
    let platformFeeRate = parseFloat(
      this.configService.get<string>('PLATFORM_FEE_PERCENTAGE', '2.5'),
    );

    // Apply pricing rules if any
    const commissionRule = await this.pricingRulesService.getActiveRule(
      'commission',
      city,
      driverId,
    );
    if (commissionRule) {
      if (commissionRule.valueType === 'percentage') {
        commissionRate = commissionRule.value;
      } else {
        // Fixed amount - convert to percentage for calculation
        commissionRate = (commissionRule.value / totalPrice) * 100;
      }
    }

    const platformFeeRule = await this.pricingRulesService.getActiveRule(
      'platform_fee',
      city,
      driverId,
    );
    if (platformFeeRule) {
      if (platformFeeRule.valueType === 'percentage') {
        platformFeeRate = platformFeeRule.value;
      } else {
        platformFeeRate = (platformFeeRule.value / totalPrice) * 100;
      }
    }

    // Calculate amounts
    const commission = (totalPrice * commissionRate) / 100;
    const platformFee = (totalPrice * platformFeeRate) / 100;
    const driverEarnings = totalPrice - commission - platformFee;

    return {
      commission: Math.round(commission * 100) / 100,
      platformFee: Math.round(platformFee * 100) / 100,
      driverEarnings: Math.round(driverEarnings * 100) / 100,
      commissionRate,
      platformFeeRate,
    };
  }

  /**
   * Create revenue records for a completed booking
   */
  async createRevenueRecords(
    bookingId: string,
    paymentId: string,
    manager?: EntityManager,
  ): Promise<RevenueRecord[]> {
    const bookingRepo = manager
      ? manager.getRepository(Booking)
      : this.bookingRepository;
    const paymentRepo = manager
      ? manager.getRepository(Payment)
      : this.paymentRepository;
    const revenueRepo = manager
      ? manager.getRepository(RevenueRecord)
      : this.revenueRepository;

    const booking = await bookingRepo.findOne({
      where: { id: bookingId },
      relations: ['vehicle', 'vehicle.driver'],
    });

    if (!booking) {
      throw new Error('Booking not found');
    }

    const payment = await paymentRepo.findOne({
      where: { id: paymentId },
    });

    if (!payment) {
      throw new Error('Payment not found');
    }

    // Calculate commission and fees
    const calculations = await this.calculateCommission(
      bookingId,
      booking.totalPrice,
      booking.vehicle?.driver?.id,
      booking.vehicle?.city,
    );

    // Update booking with calculated values
    booking.commission = calculations.commission;
    booking.driverEarnings = calculations.driverEarnings;
    await bookingRepo.save(booking);

    const records: RevenueRecord[] = [];

    // Commission record
    const commissionRecord = revenueRepo.create({
      bookingId,
      paymentId,
      revenueType: RevenueType.COMMISSION,
      amount: calculations.commission,
      commissionRate: calculations.commissionRate,
      driverId: booking.vehicle?.driver?.id,
      status: RevenueStatus.PENDING,
    });
    records.push(commissionRecord);

    // Platform fee record
    const platformFeeRecord = revenueRepo.create({
      bookingId,
      paymentId,
      revenueType: RevenueType.PLATFORM_FEE,
      amount: calculations.platformFee,
      driverId: booking.vehicle?.driver?.id,
      status: RevenueStatus.PENDING,
    });
    records.push(platformFeeRecord);

    return revenueRepo.save(records);
  }

  /**
   * Settle revenue records (for payout to drivers)
   */
  async settleRevenue(
    recordIds: string[],
    settlementPeriod: string,
    manager?: EntityManager,
  ): Promise<void> {
    const revenueRepo = manager
      ? manager.getRepository(RevenueRecord)
      : this.revenueRepository;

    await revenueRepo
      .createQueryBuilder()
      .update(RevenueRecord)
      .set({
        status: RevenueStatus.SETTLED,
        settledAt: new Date(),
        settlementPeriod,
      })
      .where('id IN (:...ids)', { ids: recordIds })
      .execute();
  }

  /**
   * Get commission summary
   */
  async getCommissionSummary(
    startDate?: Date,
    endDate?: Date,
    driverId?: string,
  ): Promise<{
    totalCommission: number;
    totalPlatformFees: number;
    totalRevenue: number;
    bookingCount: number;
  }> {
    const query = this.revenueRepository
      .createQueryBuilder('revenue')
      .where('revenue.status = :status', { status: RevenueStatus.SETTLED });

    if (startDate) {
      query.andWhere('revenue.settledAt >= :startDate', { startDate });
    }

    if (endDate) {
      query.andWhere('revenue.settledAt <= :endDate', { endDate });
    }

    if (driverId) {
      query.andWhere('revenue.driverId = :driverId', { driverId });
    }

    const [commissionRecords, feeRecords] = await Promise.all([
      query
        .clone()
        .andWhere('revenue.revenueType = :type', {
          type: RevenueType.COMMISSION,
        })
        .select('SUM(revenue.amount)', 'total')
        .getRawOne(),
      query
        .clone()
        .andWhere('revenue.revenueType = :type', {
          type: RevenueType.PLATFORM_FEE,
        })
        .select('SUM(revenue.amount)', 'total')
        .getRawOne(),
    ]);

    const totalCommission = parseFloat(commissionRecords?.total || '0');
    const totalPlatformFees = parseFloat(feeRecords?.total || '0');
    const totalRevenue = totalCommission + totalPlatformFees;

    const bookingQuery = this.bookingRepository
      .createQueryBuilder('booking')
      .where('booking.status = :status', { status: 'completed' });

    if (startDate) {
      bookingQuery.andWhere('booking.createdAt >= :startDate', { startDate });
    }
    if (endDate) {
      bookingQuery.andWhere('booking.createdAt <= :endDate', { endDate });
    }

    const bookingCount = await bookingQuery.getCount();

    return {
      totalCommission,
      totalPlatformFees,
      totalRevenue,
      bookingCount,
    };
  }
}
