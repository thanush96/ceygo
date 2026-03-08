import { Entity, PrimaryKey, Property, Index } from '@mikro-orm/core';
import { IsNotEmpty, IsString, IsUrl } from 'class-validator';
import { v4 } from 'uuid';

@Entity({ tableName: 'vehicle_brands' })
export class VehicleBrand {
  @PrimaryKey({ type: 'uuid' })
  id: string = v4();

  @Index()
  @Property({ unique: true })
  @IsString()
  @IsNotEmpty()
  name: string;

  @Property()
  @IsUrl()
  logoUrl: string;

  @Property({ default: true })
  isActive: boolean = true;

  @Property({ onCreate: () => new Date() })
  createdAt: Date = new Date();

  @Property({ onUpdate: () => new Date() })
  updatedAt: Date = new Date();
}
