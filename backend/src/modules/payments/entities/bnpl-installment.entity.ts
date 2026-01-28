import {
  Entity,
  Column,
  ManyToOne,
  JoinColumn,
} from 'typeorm';
import { BaseEntity } from '../../../common/entities/base.entity';
import { BnplPlan } from './bnpl-plan.entity';
import { Payment } from './payment.entity';

export enum BnplInstallmentStatus {
  PENDING = 'pending',
  PAID = 'paid',
  OVERDUE = 'overdue',
  FAILED = 'failed',
}

@Entity('bnpl_installments')
export class BnplInstallment extends BaseEntity {
  @Column()
  planId: string;

  @Column()
  installmentNumber: number;

  @Column({ type: 'decimal', precision: 10, scale: 2 })
  amount: number;

  @Column({ type: 'date' })
  dueDate: Date;

  @Column({ type: 'date', nullable: true })
  paidDate: Date;

  @Column({
    type: 'enum',
    enum: BnplInstallmentStatus,
    default: BnplInstallmentStatus.PENDING,
  })
  status: BnplInstallmentStatus;

  @Column({ nullable: true })
  paymentId: string;

  // Relations
  @ManyToOne(() => BnplPlan, (plan) => plan.installments)
  @JoinColumn()
  plan: BnplPlan;

  @ManyToOne(() => Payment, { nullable: true })
  @JoinColumn()
  payment: Payment;
}
