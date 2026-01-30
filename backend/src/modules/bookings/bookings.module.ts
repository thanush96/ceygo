import { Module } from '@nestjs/common';
import { MikroOrmModule } from '@mikro-orm/nestjs';
import { Booking } from './entities/booking.entity';

@Module({
  imports: [MikroOrmModule.forFeature([Booking])],
  exports: [MikroOrmModule],
})
export class BookingsModule {}
