import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { PaymentsController } from './payments.controller';
import { PaymentsService } from './payments.service';
import { Payment } from './entities/payment.entity';
import { BnplPlan } from './entities/bnpl-plan.entity';
import { BnplInstallment } from './entities/bnpl-installment.entity';
import { EmiPlan } from './entities/emi-plan.entity';
import { EmiInstallment } from './entities/emi-installment.entity';
import { BnplService } from './services/bnpl.service';
import { EmiService } from './services/emi.service';
import { Booking } from '../bookings/entities/booking.entity';
import { Wallet } from '../users/entities/wallet.entity';
import { WalletTransaction } from '../users/entities/wallet-transaction.entity';
import { RevenueModule } from '../revenue/revenue.module';

@Module({
  imports: [
    TypeOrmModule.forFeature([
      Payment,
      BnplPlan,
      BnplInstallment,
      EmiPlan,
      EmiInstallment,
      Booking,
      Wallet,
      WalletTransaction,
    ]),
    RevenueModule,
  ],
  controllers: [PaymentsController],
  providers: [PaymentsService, BnplService, EmiService],
  exports: [PaymentsService, BnplService, EmiService],
})
export class PaymentsModule {}
