import {
  Entity,
  Column,
  ManyToOne,
  JoinColumn,
} from 'typeorm';
import { BaseEntity } from '../../../common/entities/base.entity';
import { Ad } from './ad.entity';
import { User } from '../../users/entities/user.entity';

export enum AdEventType {
  IMPRESSION = 'impression',
  CLICK = 'click',
  CONVERSION = 'conversion',
}

@Entity('ad_events')
export class AdEvent extends BaseEntity {
  @Column()
  adId: string;

  @Column({
    type: 'enum',
    enum: AdEventType,
  })
  eventType: AdEventType;

  @Column({ nullable: true })
  userId: string;

  @Column({ nullable: true })
  ipAddress: string;

  @Column({ type: 'text', nullable: true })
  userAgent: string;

  @Column({ type: 'text', nullable: true })
  referrer: string;

  // Relations
  @ManyToOne(() => Ad, (ad) => ad.events)
  @JoinColumn()
  ad: Ad;

  @ManyToOne(() => User, { nullable: true })
  @JoinColumn()
  user: User;
}
