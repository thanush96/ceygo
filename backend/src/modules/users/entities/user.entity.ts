import {
  Entity,
  Column,
  OneToOne,
  OneToMany,
  JoinColumn,
} from 'typeorm';
import { BaseEntity } from '../../../common/entities/base.entity';
import { UserRole } from '../../../common/enums/user-role.enum';
import { Wallet } from './wallet.entity';
import { Booking } from '../../bookings/entities/booking.entity';

@Entity('users')
export class User extends BaseEntity {
  @Column({ unique: true })
  phoneNumber: string;

  @Column({ nullable: true })
  email: string;

  @Column()
  firstName: string;

  @Column()
  lastName: string;

  @Column({ nullable: true })
  profileImage: string;

  @Column({ nullable: true })
  dateOfBirth: Date;

  @Column({ nullable: true })
  address: string;

  @Column({ nullable: true })
  city: string;

  @Column({ nullable: true })
  country: string;

  @Column({ nullable: true })
  postalCode: string;

  @Column({ type: 'enum', enum: UserRole, default: UserRole.USER })
  role: UserRole;

  @Column({ default: false })
  isVerified: boolean;

  @Column({ default: true })
  isActive: boolean;

  @Column({ nullable: true })
  lastLoginAt: Date;

  @Column({ nullable: true })
  fcmToken: string;

  // Relations
  @OneToOne(() => Wallet, (wallet) => wallet.user, { cascade: true })
  @JoinColumn()
  wallet: Wallet;

  @OneToMany(() => Booking, (booking) => booking.user)
  bookings: Booking[];
}
