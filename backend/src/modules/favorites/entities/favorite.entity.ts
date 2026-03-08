import { Entity, PrimaryKey, Property, ManyToOne, Unique, Rel } from '@mikro-orm/core';
import { v4 } from 'uuid';
import { User } from '@modules/users/entities/user.entity';
import { Vehicle } from '@modules/vehicles/entities/vehicle.entity';

@Entity({ tableName: 'favorites' })
@Unique({ properties: ['user', 'vehicle'] })
export class Favorite {
  @PrimaryKey({ type: 'uuid' })
  id: string = v4();

  @ManyToOne(() => User, { index: true })
  user: Rel<User>;

  @ManyToOne(() => Vehicle, { index: true })
  vehicle: Rel<Vehicle>;

  @Property({ onCreate: () => new Date() })
  createdAt: Date = new Date();
}
