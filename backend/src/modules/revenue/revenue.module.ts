import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { RevenueRecord } from './entities/revenue-record.entity';
import { PricingRule } from './entities/pricing-rule.entity';
import { Subscription } from './entities/subscription.entity';
import { SubscriptionPayment } from './entities/subscription-payment.entity';
import { Ad } from './entities/ad.entity';
import { AdEvent } from './entities/ad-event.entity';
import { CommissionService } from './services/commission.service';
import { PricingRulesService } from './services/pricing-rules.service';
import { SubscriptionsService } from './services/subscriptions.service';
import { AdsService } from './services/ads.service';
import { RevenueController } from './revenue.controller';
import { BookingsModule } from '../bookings/bookings.module';
import { PaymentsModule } from '../payments/payments.module';
import { UsersModule } from '../users/users.module';

@Module({
  imports: [
    TypeOrmModule.forFeature([
      RevenueRecord,
      PricingRule,
      Subscription,
      SubscriptionPayment,
      Ad,
      AdEvent,
    ]),
    BookingsModule,
    PaymentsModule,
    UsersModule,
  ],
  controllers: [RevenueController],
  providers: [
    CommissionService,
    PricingRulesService,
    SubscriptionsService,
    AdsService,
  ],
  exports: [
    CommissionService,
    PricingRulesService,
    SubscriptionsService,
    AdsService,
  ],
})
export class RevenueModule {}
