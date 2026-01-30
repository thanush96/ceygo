import { Entity, PrimaryKey, Property, OneToMany, Collection, Rel } from '@mikro-orm/core';
import { IsNotEmpty, IsNumber, IsString, IsEnum } from 'class-validator';
import { v4 } from 'uuid';
import { Booking } from '@modules/bookings/entities/booking.entity';

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

  @Property({ unique: true })
  @IsString()
  @IsNotEmpty()
  plateNo: string;

  @Property()
  @IsEnum(['available', 'booked', 'maintenance'])
  status: string = 'available';

  @OneToMany(() => Booking, (booking: Booking) => booking.vehicle)
  bookings = new Collection<Booking>(this);

  @Property({ onCreate: () => new Date() })
  createdAt: Date = new Date();

  @Property({ onUpdate: () => new Date() })
  updatedAt: Date = new Date();
}
