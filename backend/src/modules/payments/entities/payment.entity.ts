import { Entity, PrimaryKey, Property, OneToOne, Rel } from '@mikro-orm/core';
import { IsNumber, IsString, IsEnum } from 'class-validator';
import { v4 } from 'uuid';
import { Booking } from '@modules/bookings/entities/booking.entity';

@Entity({ tableName: 'payments' })
export class Payment {
  @PrimaryKey({ type: 'uuid' })
  id: string = v4();

  @OneToOne(() => Booking, (booking: Booking) => booking.payment)
  booking!: Rel<Booking>;

  @Property({ type: 'decimal', precision: 10, scale: 2 })
  @IsNumber()
  amount!: number;

  @Property()
  @IsEnum(['pending', 'success', 'failed'])
  status: string = 'pending';

  @Property({ nullable: true })
  @IsString()
  gatewayRef?: string;

  @Property()
  @IsEnum(['PayHere', 'GPay', 'Card'])
  method: string;

  @Property({ onCreate: () => new Date() })
  createdAt: Date = new Date();

  @Property({ onUpdate: () => new Date() })
  updatedAt: Date = new Date();
}
