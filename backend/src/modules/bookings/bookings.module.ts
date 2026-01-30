import { Module } from '@nestjs/common';
import { MikroOrmModule } from '@mikro-orm/nestjs';
import { Booking } from './entities/booking.entity';
import { Vehicle } from '@modules/vehicles/entities/vehicle.entity';
import { User } from '@modules/users/entities/user.entity';
import { Payment } from '@modules/payments/entities/payment.entity';
import { BookingService } from './booking.service';
import { BookingController } from './booking.controller';
import { PaymentsModule } from '@modules/payments/payments.module';

@Module({
  imports: [
    MikroOrmModule.forFeature([Booking, Vehicle, User, Payment]),
    PaymentsModule,
  ],
  controllers: [BookingController],
  providers: [BookingService],
  exports: [BookingService, MikroOrmModule],
})
export class BookingsModule {}
