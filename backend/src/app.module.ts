import { Module } from '@nestjs/common';
import { ConfigModule, ConfigService } from '@nestjs/config';
import { MikroOrmModule } from '@mikro-orm/nestjs';
import { PostgreSqlDriver } from '@mikro-orm/postgresql';
import { AuthModule } from './modules/auth/auth.module';
import { UsersModule } from './modules/users/users.module';
import { VehiclesModule } from './modules/vehicles/vehicles.module';
import { BookingsModule } from './modules/bookings/bookings.module';
import { PaymentsModule } from './modules/payments/payments.module';
import { ChatModule } from './modules/chat/chat.module';
import { AdminModule } from './modules/admin/admin.module';

@Module({
  imports: [
    // Global Configuration
    ConfigModule.forRoot({
      isGlobal: true,
      envFilePath: '.env',
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
      }),
    }),

    // Feature Modules
    AuthModule,
    UsersModule,
    VehiclesModule,
    BookingsModule,
    PaymentsModule,
    ChatModule,
    AdminModule,
  ],
})
export class AppModule {}
