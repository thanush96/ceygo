import {
  Entity,
  Column,
  ManyToOne,
  JoinColumn,
} from 'typeorm';
import { BaseEntity } from '../../../common/entities/base.entity';
import { User } from '../../users/entities/user.entity';

export enum RuleType {
  COMMISSION = 'commission',
  PLATFORM_FEE = 'platform_fee',
  DISCOUNT = 'discount',
  SURCHARGE = 'surcharge',
}

export enum TargetType {
  ALL = 'all',
  CITY = 'city',
  VEHICLE_TYPE = 'vehicle_type',
  USER_TIER = 'user_tier',
}

export enum ValueType {
  PERCENTAGE = 'percentage',
  FIXED = 'fixed',
}

@Entity('pricing_rules')
export class PricingRule extends BaseEntity {
  @Column()
  ruleName: string;

  @Column({
    type: 'enum',
    enum: RuleType,
  })
  ruleType: RuleType;

  @Column({
    type: 'enum',
    enum: TargetType,
    nullable: true,
  })
  targetType: TargetType;

  @Column({ nullable: true })
  targetValue: string;

  @Column({ type: 'decimal', precision: 10, scale: 2 })
  value: number;

  @Column({
    type: 'enum',
    enum: ValueType,
  })
  valueType: ValueType;

  @Column({ default: true })
  isActive: boolean;

  @Column({ type: 'date', nullable: true })
  startDate: Date;

  @Column({ type: 'date', nullable: true })
  endDate: Date;

  @Column({ default: 0 })
  priority: number;

  @Column({ nullable: true })
  createdBy: string;

  // Relations
  @ManyToOne(() => User, { nullable: true })
  @JoinColumn()
  creator: User;
}
