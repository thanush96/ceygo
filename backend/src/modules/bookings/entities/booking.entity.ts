import {
  Entity,
  Column,
  ManyToOne,
  OneToOne,
  JoinColumn,
} from 'typeorm';
import { BaseEntity } from '../../../common/entities/base.entity';
import { BookingStatus } from '../../../common/enums/booking-status.enum';
import { User } from '../../users/entities/user.entity';
import { Vehicle } from '../../vehicles/entities/vehicle.entity';
import { Payment } from '../../payments/entities/payment.entity';

@Entity('bookings')
export class Booking extends BaseEntity {
  @Column()
  userId: string;

  @Column()
  vehicleId: string;

  @Column({ type: 'timestamp' })
  startDate: Date;

  @Column({ type: 'timestamp' })
  endDate: Date;

  @Column({ type: 'time', nullable: true })
  pickupTime: string;

  @Column()
  pickupLocation: string;

  @Column({ nullable: true })
  dropoffLocation: string;

  @Column({ type: 'decimal', precision: 10, scale: 2 })
  totalPrice: number;

  @Column({ type: 'decimal', precision: 10, scale: 2, nullable: true })
  commission: number;

  @Column({ type: 'decimal', precision: 10, scale: 2, nullable: true })
  driverEarnings: number;

  @Column({ type: 'enum', enum: BookingStatus, default: BookingStatus.PENDING })
  status: BookingStatus;

  @Column({ nullable: true })
  cancellationReason: string;

  @Column({ type: 'timestamp', nullable: true })
  cancelledAt: Date;

  @Column({ nullable: true })
  notes: string;

  // Relations
  @ManyToOne(() => User, (user) => user.bookings)
  @JoinColumn()
  user: User;

  @ManyToOne(() => Vehicle, (vehicle) => vehicle.bookings)
  @JoinColumn()
  vehicle: Vehicle;

  @OneToOne(() => Payment, (payment) => payment.booking)
  payment: Payment;
}
