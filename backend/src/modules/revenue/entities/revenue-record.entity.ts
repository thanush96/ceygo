import {
  Entity,
  Column,
  ManyToOne,
  JoinColumn,
} from 'typeorm';
import { BaseEntity } from '../../../common/entities/base.entity';
import { Booking } from '../../bookings/entities/booking.entity';
import { Payment } from '../../payments/entities/payment.entity';
import { Driver } from '../../drivers/entities/driver.entity';
import { User } from '../../users/entities/user.entity';

export enum RevenueType {
  COMMISSION = 'commission',
  PLATFORM_FEE = 'platform_fee',
  SUBSCRIPTION = 'subscription',
  ADS = 'ads',
  OTHER = 'other',
}

export enum RevenueStatus {
  PENDING = 'pending',
  SETTLED = 'settled',
  CANCELLED = 'cancelled',
}

@Entity('revenue_records')
export class RevenueRecord extends BaseEntity {
  @Column()
  bookingId: string;

  @Column()
  paymentId: string;

  @Column({
    type: 'enum',
    enum: RevenueType,
  })
  revenueType: RevenueType;

  @Column({ type: 'decimal', precision: 10, scale: 2 })
  amount: number;

  @Column({ type: 'decimal', precision: 5, scale: 2, nullable: true })
  commissionRate: number;

  @Column({ nullable: true })
  driverId: string;

  @Column({ nullable: true })
  userId: string;

  @Column({
    type: 'enum',
    enum: RevenueStatus,
    default: RevenueStatus.PENDING,
  })
  status: RevenueStatus;

  @Column({ type: 'timestamp', nullable: true })
  settledAt: Date;

  @Column({ nullable: true })
  settlementPeriod: string;

  // Relations
  @ManyToOne(() => Booking)
  @JoinColumn()
  booking: Booking;

  @ManyToOne(() => Payment)
  @JoinColumn()
  payment: Payment;

  @ManyToOne(() => Driver, { nullable: true })
  @JoinColumn()
  driver: Driver;

  @ManyToOne(() => User, { nullable: true })
  @JoinColumn()
  user: User;
}
