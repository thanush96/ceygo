import { Module } from '@nestjs/common';
import { MikroOrmModule } from '@mikro-orm/nestjs';
import { AdminService } from './admin.service';
import { AdminController } from './admin.controller';
import { User } from '@modules/users/entities/user.entity';
import { Vehicle } from '@modules/vehicles/entities/vehicle.entity';
import { Booking } from '@modules/bookings/entities/booking.entity';
import { Payment } from '@modules/payments/entities/payment.entity';
import { CommonModule } from '@common/common.module';

@Module({
  imports: [
    MikroOrmModule.forFeature([User, Vehicle, Booking, Payment]),
    CommonModule,
  ],
  controllers: [AdminController],
  providers: [AdminService],
  exports: [AdminService],
})
export class AdminModule {}
