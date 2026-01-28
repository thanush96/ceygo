import {
  Entity,
  Column,
  ManyToOne,
  OneToMany,
  JoinColumn,
} from 'typeorm';
import { BaseEntity } from '../../../common/entities/base.entity';
import { Payment } from './payment.entity';
import { Booking } from '../../bookings/entities/booking.entity';
import { BnplInstallment } from './bnpl-installment.entity';

export enum BnplPlanStatus {
  ACTIVE = 'active',
  COMPLETED = 'completed',
  DEFAULTED = 'defaulted',
  CANCELLED = 'cancelled',
}

@Entity('bnpl_plans')
export class BnplPlan extends BaseEntity {
  @Column()
  paymentId: string;

  @Column()
  bookingId: string;

  @Column({ type: 'decimal', precision: 10, scale: 2 })
  totalAmount: number;

  @Column()
  installmentCount: number;

  @Column({ type: 'decimal', precision: 10, scale: 2 })
  installmentAmount: number;

  @Column({ type: 'decimal', precision: 5, scale: 2, default: 0 })
  interestRate: number;

  @Column({ type: 'date' })
  firstPaymentDate: Date;

  @Column({ type: 'date' })
  lastPaymentDate: Date;

  @Column({
    type: 'enum',
    enum: BnplPlanStatus,
    default: BnplPlanStatus.ACTIVE,
  })
  status: BnplPlanStatus;

  @Column({ nullable: true })
  provider: string;

  @Column({ nullable: true })
  providerPlanId: string;

  // Relations
  @ManyToOne(() => Payment, (payment) => payment.bnplPlans)
  @JoinColumn()
  payment: Payment;

  @ManyToOne(() => Booking)
  @JoinColumn()
  booking: Booking;

  @OneToMany(() => BnplInstallment, (installment) => installment.plan)
  installments: BnplInstallment[];
}
