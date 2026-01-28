import {
  Entity,
  Column,
  ManyToOne,
  JoinColumn,
} from 'typeorm';
import { BaseEntity } from '../../../common/entities/base.entity';
import { EmiPlan } from './emi-plan.entity';
import { Payment } from './payment.entity';

export enum EmiInstallmentStatus {
  PENDING = 'pending',
  PAID = 'paid',
  OVERDUE = 'overdue',
  FAILED = 'failed',
}

@Entity('emi_installments')
export class EmiInstallment extends BaseEntity {
  @Column()
  planId: string;

  @Column()
  installmentNumber: number;

  @Column({ type: 'decimal', precision: 10, scale: 2 })
  principalAmount: number;

  @Column({ type: 'decimal', precision: 10, scale: 2 })
  interestAmount: number;

  @Column({ type: 'decimal', precision: 10, scale: 2 })
  totalAmount: number;

  @Column({ type: 'date' })
  dueDate: Date;

  @Column({ type: 'date', nullable: true })
  paidDate: Date;

  @Column({
    type: 'enum',
    enum: EmiInstallmentStatus,
    default: EmiInstallmentStatus.PENDING,
  })
  status: EmiInstallmentStatus;

  @Column({ nullable: true })
  paymentId: string;

  // Relations
  @ManyToOne(() => EmiPlan, (plan) => plan.installments)
  @JoinColumn()
  plan: EmiPlan;

  @ManyToOne(() => Payment, { nullable: true })
  @JoinColumn()
  payment: Payment;
}
