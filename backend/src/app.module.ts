import { Module } from '@nestjs/common';
import { ConfigModule, ConfigService } from '@nestjs/config';
import { MikroOrmModule } from '@mikro-orm/nestjs';
import { PostgreSqlDriver } from '@mikro-orm/postgresql';
import { ThrottlerModule } from '@nestjs/throttler';
import { AuthModule } from './modules/auth/auth.module';
import { UsersModule } from './modules/users/users.module';
import { VehiclesModule } from './modules/vehicles/vehicles.module';
import { BookingsModule } from './modules/bookings/bookings.module';
import { PaymentsModule } from './modules/payments/payments.module';
import { ChatModule } from './modules/chat/chat.module';
import { AdminModule } from './modules/admin/admin.module';
import { APP_GUARD, APP_INTERCEPTOR } from '@nestjs/core';
import { ThrottlerGuard } from '@nestjs/throttler';
import { SmartCacheInterceptor } from './common/interceptors/smart-cache.interceptor';
import { CacheModule } from '@nestjs/cache-manager';
import { HealthController } from './health.controller';
import { QueuesModule } from './common/queues/queues.module';
import { CommonModule } from './common/common.module';

@Module({
  imports: [
    // Global Configuration
    ConfigModule.forRoot({
      isGlobal: true,
      envFilePath: '.env',
    }),

    CacheModule.register({
      isGlobal: true,
      ttl: 60 * 1000, // 1 minute default
    }),

    MikroOrmModule.forRootAsync({
      imports: [ConfigModule],
      inject: [ConfigService],
      useFactory: (configService: ConfigService) => ({
        driver: PostgreSqlDriver,
        host: configService.get<string>('DB_HOST'),
        port: configService.get<number>('DB_PORT'),
        user: configService.get<string>('DB_USERNAME'),
        password: configService.get<string>('DB_PASSWORD'),
        dbName: configService.get<string>('DB_DATABASE'),
        entities: ['dist/**/*.entity.js'],
        entitiesTs: ['src/**/*.entity.ts'],
        debug: configService.get<string>('NODE_ENV') === 'development',
        allowGlobalContext: true,
        driverOptions: {
          connection: {
            ssl: configService.get<string>('DB_SSL') === 'true' ? { rejectUnauthorized: false } : false,
          },
        },
        pool: { min: 2, max: 20 },
      }),
    }),

    ThrottlerModule.forRoot([{
      name: 'default',
      ttl: 60000,
      limit: 100,
    }, {
      name: 'auth',
      ttl: 60000,
      limit: 5,
    }, {
      name: 'search',
      ttl: 60000,
      limit: 60,
    }, {
      name: 'booking',
      ttl: 60000,
      limit: 10,
    }]),

    // Feature Modules
    AuthModule,
    UsersModule,
    VehiclesModule,
    BookingsModule,
    PaymentsModule,
    ChatModule,
    AdminModule,
    QueuesModule,
    CommonModule,
  ],
  providers: [
    {
      provide: APP_GUARD,
      useClass: ThrottlerGuard,
    },
    {
      provide: APP_INTERCEPTOR,
      useClass: SmartCacheInterceptor,
    },
  ],
  controllers: [HealthController],
})
 export class AppModule {}
