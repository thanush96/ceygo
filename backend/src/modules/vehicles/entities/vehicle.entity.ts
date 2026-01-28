import {
  Entity,
  Column,
  ManyToOne,
  OneToMany,
  JoinColumn,
} from 'typeorm';
import { BaseEntity } from '../../../common/entities/base.entity';
import { VehicleStatus } from '../../../common/enums/vehicle-status.enum';
import { Driver } from '../../drivers/entities/driver.entity';
import { Booking } from '../../bookings/entities/booking.entity';
import { VehicleImage } from './vehicle-image.entity';

@Entity('vehicles')
export class Vehicle extends BaseEntity {
  @Column()
  make: string;

  @Column()
  model: string;

  @Column()
  year: number;

  @Column()
  color: string;

  @Column({ unique: true })
  licensePlate: string;

  @Column()
  vin: string;

  @Column({ type: 'decimal', precision: 10, scale: 2 })
  pricePerDay: number;

  @Column({ type: 'decimal', precision: 10, scale: 2, nullable: true })
  pricePerHour: number;

  @Column({ type: 'decimal', precision: 10, scale: 2, nullable: true })
  pricePerWeek: number;

  @Column({ type: 'decimal', precision: 10, scale: 2, nullable: true })
  pricePerMonth: number;

  @Column()
  seats: number;

  @Column()
  transmission: string; // Manual, Automatic

  @Column()
  fuelType: string; // Petrol, Diesel, Electric, Hybrid

  @Column({ type: 'decimal', precision: 5, scale: 2, default: 0 })
  rating: number;

  @Column({ default: 0 })
  tripCount: number;

  @Column({ type: 'text', nullable: true })
  description: string;

  @Column({ type: 'enum', enum: VehicleStatus, default: VehicleStatus.PENDING })
  status: VehicleStatus;

  @Column({ nullable: true })
  location: string;

  @Column({ type: 'decimal', precision: 10, scale: 7, nullable: true })
  latitude: number;

  @Column({ type: 'decimal', precision: 10, scale: 7, nullable: true })
  longitude: number;

  @Column({ default: true })
  isAvailable: boolean;

  @Column({ nullable: true })
  insuranceNumber: string;

  @Column({ nullable: true })
  insuranceExpiryDate: Date;

  @Column({ nullable: true })
  registrationExpiryDate: Date;

  // Relations
  @ManyToOne(() => Driver, (driver) => driver.vehicles)
  @JoinColumn()
  driver: Driver;

  @Column()
  driverId: string;

  @OneToMany(() => Booking, (booking) => booking.vehicle)
  bookings: Booking[];

  @OneToMany(() => VehicleImage, (image) => image.vehicle, { cascade: true })
  images: VehicleImage[];
}
