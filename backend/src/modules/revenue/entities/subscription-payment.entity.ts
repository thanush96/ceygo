import {
  Entity,
  Column,
  ManyToOne,
  JoinColumn,
} from 'typeorm';
import { BaseEntity } from '../../../common/entities/base.entity';
import { Subscription } from './subscription.entity';
import { Payment } from '../../payments/entities/payment.entity';

export enum SubscriptionPaymentStatus {
  PENDING = 'pending',
  COMPLETED = 'completed',
  FAILED = 'failed',
}

@Entity('subscription_payments')
export class SubscriptionPayment extends BaseEntity {
  @Column()
  subscriptionId: string;

  @Column({ type: 'decimal', precision: 10, scale: 2 })
  amount: number;

  @Column({ type: 'date' })
  paymentDate: Date;

  @Column({
    type: 'enum',
    enum: SubscriptionPaymentStatus,
    default: SubscriptionPaymentStatus.PENDING,
  })
  status: SubscriptionPaymentStatus;

  @Column({ nullable: true })
  paymentId: string;

  // Relations
  @ManyToOne(() => Subscription, (subscription) => subscription.payments)
  @JoinColumn()
  subscription: Subscription;

  @ManyToOne(() => Payment, { nullable: true })
  @JoinColumn()
  payment: Payment;
}
