import { Module, forwardRef } from '@nestjs/common';
import { MikroOrmModule } from '@mikro-orm/nestjs';
import { CacheModule } from '@nestjs/cache-manager';
import { Payment } from './entities/payment.entity';
import { PayHereService } from './payhere.service';
import { CurrencyService } from './currency.service';
import { PaymentsController } from './payments.controller';
import { BookingsModule } from '@modules/bookings/bookings.module';

@Module({
  imports: [
    MikroOrmModule.forFeature([Payment]),
    CacheModule.registerAsync({
      useFactory: () => ({}), // Uses global redis config if available or defaults
    }),
    forwardRef(() => BookingsModule),
  ],
  controllers: [PaymentsController],
  providers: [PayHereService, CurrencyService],
  exports: [PayHereService, CurrencyService, MikroOrmModule],
})
export class PaymentsModule {}
