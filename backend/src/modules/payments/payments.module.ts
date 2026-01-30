import { Module } from '@nestjs/common';
import { MikroOrmModule } from '@mikro-orm/nestjs';
import { Payment } from './entities/payment.entity';
import { PayHereService } from './payhere.service';

@Module({
  imports: [MikroOrmModule.forFeature([Payment])],
  providers: [PayHereService],
  exports: [PayHereService, MikroOrmModule],
})
export class PaymentsModule {}
