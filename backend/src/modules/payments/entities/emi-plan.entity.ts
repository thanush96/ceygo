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
import { EmiInstallment } from './emi-installment.entity';

export enum EmiPlanStatus {
  ACTIVE = 'active',
  COMPLETED = 'completed',
  DEFAULTED = 'defaulted',
  CANCELLED = 'cancelled',
}

@Entity('emi_plans')
export class EmiPlan extends BaseEntity {
  @Column()
  paymentId: string;

  @Column()
  bookingId: string;

  @Column({ type: 'decimal', precision: 10, scale: 2 })
  principalAmount: number;

  @Column({ type: 'decimal', precision: 5, scale: 2 })
  interestRate: number;

  @Column()
  tenureMonths: number;

  @Column({ type: 'decimal', precision: 10, scale: 2 })
  emiAmount: number;

  @Column({ type: 'decimal', precision: 10, scale: 2 })
  totalAmount: number;

  @Column({ type: 'date' })
  firstPaymentDate: Date;

  @Column({
    type: 'enum',
    enum: EmiPlanStatus,
    default: EmiPlanStatus.ACTIVE,
  })
  status: EmiPlanStatus;

  @Column({ nullable: true })
  bankName: string;

  // Relations
  @ManyToOne(() => Payment, (payment) => payment.emiPlans)
  @JoinColumn()
  payment: Payment;

  @ManyToOne(() => Booking)
  @JoinColumn()
  booking: Booking;

  @OneToMany(() => EmiInstallment, (installment) => installment.plan)
  installments: EmiInstallment[];
}
