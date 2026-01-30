import { Entity, PrimaryKey, Property, OneToMany, ManyToOne, Collection, Rel, Index } from '@mikro-orm/core';
import { IsNotEmpty, IsNumber, IsString, IsEnum, IsUrl, IsBoolean, Matches, Min, Max } from 'class-validator';
import { v4 } from 'uuid';
import { Booking } from '@modules/bookings/entities/booking.entity';
import { User } from '@modules/users/entities/user.entity';

@Entity({ tableName: 'vehicles' })
export class Vehicle {
  @PrimaryKey({ type: 'uuid' })
  id: string = v4();

  @Property()
  @IsString()
  @IsNotEmpty()
  name: string;

  @Property()
  @IsString()
  @IsNotEmpty()
  brand: string;

  @Property({ nullable: true })
  @IsUrl()
  brandLogo: string;

  @Property({ nullable: true })
  @IsUrl()
  imageUrl: string;

  @Property({ type: 'decimal', precision: 10, scale: 2 })
  @IsNumber()
  pricePerDay: number;

  @Property()
  @IsNumber()
  seats: number;

  @Property()
  @IsEnum(['Manual', 'Auto'])
  transmission: string;

  @Property()
  @IsEnum(['Petrol', 'Diesel', 'Electric', 'Hybrid'])
  fuelType: string;

  @Property({ type: 'decimal', precision: 2, scale: 1, default: 0 })
  @IsNumber()
  @Min(0)
  @Max(5)
  rating: number;

  @Property({ default: 0 })
  @IsNumber()
  tripCount: number;

  @ManyToOne(() => User)
  owner!: Rel<User>;

  @Property({ unique: true })
  @IsString()
  @IsNotEmpty()
  @Matches(/^(?:[A-Z]{1,3}-[0-9]{4}|[0-9]{1,3}-[0-9]{4})$/, {
    message: 'Plate number must be a valid Sri Lankan format (e.g., WP CAB-1234 or 15-1234)',
  })
  plateNo: string;

  @Property({ default: false })
  @IsBoolean()
  airportPickupAvailable: boolean;

  @Index()
  @Property()
  @IsEnum(['available', 'rented', 'maintenance'])
  status: string = 'available';

  @Property({ default: 'pending' })
  @IsEnum(['pending', 'approved', 'rejected'])
  verificationStatus: string = 'pending';

  @Property({ default: false })
  @IsBoolean()
  isBlacklisted: boolean = false;

  @Property({ nullable: true })
  @IsString()
  reason?: string;

  @Property({ type: 'text', nullable: true })
  @IsString()
  location: string;

  @Property({ type: 'decimal', precision: 10, scale: 8, nullable: true })
  @IsNumber()
  lat: number;

  @Property({ type: 'decimal', precision: 11, scale: 8, nullable: true })
  @IsNumber()
  lng: number;

  @OneToMany(() => Booking, (booking: Booking) => booking.vehicle)
  bookings = new Collection<Booking>(this);

  @Property({ nullable: true })
  deletedAt?: Date;

  @Property({ onCreate: () => new Date() })
  createdAt: Date = new Date();

  @Property({ onUpdate: () => new Date() })
  updatedAt: Date = new Date();
}
