import { Entity, PrimaryKey, Property, ManyToOne, OneToOne, Rel, Index } from '@mikro-orm/core';
import { IsDate, IsNumber, IsString, IsEnum, IsOptional } from 'class-validator';
import { v4 } from 'uuid';
import { User } from '@modules/users/entities/user.entity';
import { Vehicle } from '@modules/vehicles/entities/vehicle.entity';
import { Payment } from '@modules/payments/entities/payment.entity';

@Entity({ tableName: 'bookings' })
export class Booking {
  @PrimaryKey({ type: 'uuid' })
  id: string = v4();

  @ManyToOne(() => User)
  renter!: Rel<User>;

  @ManyToOne(() => Vehicle)
  vehicle!: Rel<Vehicle>;

  @Index()
  @Property()
  @IsDate()
  startDate!: Date;

  @Index()
  @Property()
  @IsDate()
  endDate!: Date;

  @Property({ type: 'text' })
  @IsString()
  pickupLocation: string;

  @Property({ type: 'text' })
  @IsString()
  dropoffLocation: string;

  @Property({ nullable: true })
  @IsString()
  @IsOptional()
  flightNumber?: string;

  @Property({ type: 'decimal', precision: 10, scale: 2 })
  @IsNumber()
  totalPrice!: number;

  @Property()
  @IsEnum(['LKR', 'USD'])
  currency: string = 'LKR';

  @Property()
  @IsEnum(['pending', 'confirmed', 'paid', 'completed', 'cancelled'])
  status: string = 'pending';

  @OneToOne(() => Payment, (payment: Payment) => payment.booking, { nullable: true, owner: true })
  payment?: Rel<Payment>;

  @Property({ onCreate: () => new Date() })
  createdAt: Date = new Date();

  @Property({ onUpdate: () => new Date() })
  updatedAt: Date = new Date();
}
