import {
  Entity,
  Column,
  ManyToOne,
  OneToMany,
  JoinColumn,
} from 'typeorm';
import { BaseEntity } from '../../../common/entities/base.entity';
import { User } from '../../users/entities/user.entity';
import { SubscriptionPayment } from './subscription-payment.entity';

export enum SubscriptionPlanType {
  BASIC = 'basic',
  PREMIUM = 'premium',
  ENTERPRISE = 'enterprise',
}

export enum SubscriptionStatus {
  ACTIVE = 'active',
  CANCELLED = 'cancelled',
  EXPIRED = 'expired',
  SUSPENDED = 'suspended',
}

@Entity('subscriptions')
export class Subscription extends BaseEntity {
  @Column()
  userId: string;

  @Column({
    type: 'enum',
    enum: SubscriptionPlanType,
  })
  planType: SubscriptionPlanType;

  @Column()
  planName: string;

  @Column({ type: 'decimal', precision: 10, scale: 2 })
  pricePerMonth: number;

  @Column({ type: 'decimal', precision: 5, scale: 2, default: 0 })
  discountPercentage: number;

  @Column({
    type: 'enum',
    enum: SubscriptionStatus,
    default: SubscriptionStatus.ACTIVE,
  })
  status: SubscriptionStatus;

  @Column({ type: 'date' })
  startDate: Date;

  @Column({ type: 'date', nullable: true })
  endDate: Date;

  @Column({ default: true })
  autoRenew: boolean;

  @Column({ nullable: true })
  paymentMethod: string;

  // Relations
  @ManyToOne(() => User)
  @JoinColumn()
  user: User;

  @OneToMany(() => SubscriptionPayment, (payment) => payment.subscription)
  payments: SubscriptionPayment[];
}
