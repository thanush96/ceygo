import { Entity, PrimaryKey, Property, OneToMany, Collection, Rel } from '@mikro-orm/core';
import { IsEmail, IsNotEmpty, IsString, Matches, IsEnum } from 'class-validator';
import { v4 } from 'uuid';
import { Booking } from '@modules/bookings/entities/booking.entity';

@Entity({ tableName: 'users' })
export class User {
  @PrimaryKey({ type: 'uuid' })
  id: string = v4();

  @Property()
  @IsString()
  @IsNotEmpty()
  name: string;

  @Property({ unique: true })
  @IsEmail()
  email: string;

  @Property({ unique: true })
  @IsString()
  @IsNotEmpty()
  @Matches(/^(?:\+94|0)7[0-9]{8}$/, {
    message: 'Mobile number must be a valid Sri Lankan format (e.g., +94771234567 or 0771234567)',
  })
  phone: string;

  @Property({ unique: true })
  @IsString()
  @IsNotEmpty()
  @Matches(/^(?:[0-9]{9}[xXvV]|[0-9]{12})$/, {
    message: 'NIC must be a valid Sri Lankan format (e.g., 941234567V or 199412345678)',
  })
  nic: string;

  @Property()
  @IsEnum(['renter', 'owner', 'admin'])
  role: string = 'renter';

  @OneToMany(() => Booking, (booking: Booking) => booking.user)
  bookings = new Collection<Booking>(this);

  @Property({ onCreate: () => new Date() })
  createdAt: Date = new Date();

  @Property({ onUpdate: () => new Date() })
  updatedAt: Date = new Date();
}
