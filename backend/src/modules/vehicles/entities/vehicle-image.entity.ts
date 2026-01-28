import {
  Entity,
  Column,
  ManyToOne,
  JoinColumn,
} from 'typeorm';
import { BaseEntity } from '../../../common/entities/base.entity';
import { Vehicle } from './vehicle.entity';

@Entity('vehicle_images')
export class VehicleImage extends BaseEntity {
  @Column()
  url: string;

  @Column()
  key: string; // S3 key

  @Column({ default: false })
  isPrimary: boolean;

  @Column({ nullable: true })
  caption: string;

  // Relations
  @ManyToOne(() => Vehicle, (vehicle) => vehicle.images, { onDelete: 'CASCADE' })
  @JoinColumn()
  vehicle: Vehicle;

  @Column()
  vehicleId: string;
}
