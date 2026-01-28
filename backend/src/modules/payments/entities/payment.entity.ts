import {
  Entity,
  Column,
  OneToOne,
  OneToMany,
  JoinColumn,
} from 'typeorm';
import { BaseEntity } from '../../../common/entities/base.entity';
import { PaymentStatus } from '../../../common/enums/payment-status.enum';
import { PaymentMethod } from '../../../common/enums/payment-method.enum';
import { Booking } from '../../bookings/entities/booking.entity';
import { BnplPlan } from './bnpl-plan.entity';
import { EmiPlan } from './emi-plan.entity';

@Entity('payments')
export class Payment extends BaseEntity {
  @Column()
  bookingId: string;

  @Column({ type: 'decimal', precision: 10, scale: 2 })
  amount: number;

  @Column({ type: 'enum', enum: PaymentMethod })
  method: PaymentMethod;

  @Column({ type: 'enum', enum: PaymentStatus, default: PaymentStatus.PENDING })
  status: PaymentStatus;

  @Column({ nullable: true })
  transactionId: string;

  @Column({ type: 'jsonb', nullable: true })
  gatewayResponse: Record<string, any>; // JSON object of gateway response

  @Column({ nullable: true })
  gatewayTransactionId: string;

  @Column({ nullable: true })
  refundTransactionId: string;

  @Column({ type: 'decimal', precision: 10, scale: 2, nullable: true })
  refundAmount: number;

  @Column({ type: 'timestamp', nullable: true })
  refundedAt: Date;

  @Column({ nullable: true })
  failureReason: string;

  @Column({ default: false })
  isBnpl: boolean;

  @Column({ nullable: true })
  bnplPlanId: string;

  @Column({ default: false })
  isEmi: boolean;

  @Column({ nullable: true })
  emiPlanId: string;

  // Relations
  @OneToOne(() => Booking, (booking) => booking.payment)
  @JoinColumn()
  booking: Booking;

  @OneToMany(() => BnplPlan, (plan) => plan.payment)
  bnplPlans: BnplPlan[];

  @OneToMany(() => EmiPlan, (plan) => plan.payment)
  emiPlans: EmiPlan[];
}
