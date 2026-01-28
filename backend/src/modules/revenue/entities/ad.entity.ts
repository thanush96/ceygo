import {
  Entity,
  Column,
  ManyToOne,
  OneToMany,
  JoinColumn,
} from 'typeorm';
import { BaseEntity } from '../../../common/entities/base.entity';
import { User } from '../../users/entities/user.entity';
import { AdEvent } from './ad-event.entity';

export enum AdType {
  BANNER = 'banner',
  INTERSTITIAL = 'interstitial',
  VIDEO = 'video',
  NATIVE = 'native',
}

export enum AdPlacement {
  HOME = 'home',
  SEARCH = 'search',
  VEHICLE_DETAIL = 'vehicle_detail',
  BOOKING = 'booking',
}

export enum AdStatus {
  ACTIVE = 'active',
  PAUSED = 'paused',
  EXPIRED = 'expired',
  REJECTED = 'rejected',
}

@Entity('ads')
export class Ad extends BaseEntity {
  @Column({ nullable: true })
  advertiserId: string;

  @Column()
  title: string;

  @Column({ type: 'text', nullable: true })
  description: string;

  @Column({ type: 'text' })
  imageUrl: string;

  @Column({ type: 'text', nullable: true })
  linkUrl: string;

  @Column({
    type: 'enum',
    enum: AdType,
    nullable: true,
  })
  adType: AdType;

  @Column({
    type: 'enum',
    enum: AdPlacement,
    nullable: true,
  })
  placement: AdPlacement;

  @Column({
    type: 'enum',
    enum: AdStatus,
    default: AdStatus.ACTIVE,
  })
  status: AdStatus;

  @Column({ type: 'date' })
  startDate: Date;

  @Column({ type: 'date', nullable: true })
  endDate: Date;

  @Column({ type: 'decimal', precision: 10, scale: 2 })
  budget: number;

  @Column({ type: 'decimal', precision: 10, scale: 2, default: 0 })
  spent: number;

  @Column({ default: 0 })
  impressions: number;

  @Column({ default: 0 })
  clicks: number;

  @Column({ type: 'decimal', precision: 5, scale: 2, default: 0 })
  ctr: number; // Click-through rate

  // Relations
  @ManyToOne(() => User, { nullable: true })
  @JoinColumn()
  advertiser: User;

  @OneToMany(() => AdEvent, (event) => event.ad)
  events: AdEvent[];
}
