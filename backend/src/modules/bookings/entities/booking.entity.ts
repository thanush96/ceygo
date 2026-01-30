import { Entity, PrimaryKey, Property, ManyToOne, Rel } from '@mikro-orm/core';
import { IsDate, IsNumber, IsString, IsEnum } from 'class-validator';
import { v4 } from 'uuid';
import { User } from '@modules/users/entities/user.entity';
import { Vehicle } from '@modules/vehicles/entities/vehicle.entity';

@Entity({ tableName: 'bookings' })
export class Booking {
  @PrimaryKey({ type: 'uuid' })
  id: string = v4();

  @ManyToOne(() => User)
  user!: Rel<User>;

  @ManyToOne(() => Vehicle)
  vehicle!: Rel<Vehicle>;

  @Property()
  @IsDate()
  startDate!: Date;

  @Property()
  @IsDate()
  endDate!: Date;

  @Property({ type: 'decimal', precision: 10, scale: 2 })
  @IsNumber()
  totalPrice!: number;

  @Property()
  @IsEnum(['pending', 'confirmed', 'completed', 'cancelled'])
  status: string = 'pending';

  @Property({ onCreate: () => new Date() })
  createdAt: Date = new Date();

  @Property({ onUpdate: () => new Date() })
  updatedAt: Date = new Date();
}
