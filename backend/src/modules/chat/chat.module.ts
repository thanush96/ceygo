import { Module } from '@nestjs/common';
import { MikroOrmModule } from '@mikro-orm/nestjs';
import { JwtModule } from '@nestjs/jwt';
import { CacheModule } from '@nestjs/cache-manager';
import { ChatMessage } from './entities/chat-message.entity';
import { ChatService } from './chat.service';
import { ChatGateway } from './chat.gateway';
import { ChatController } from './chat.controller';
import { NotificationService } from './notification.service';
import { User } from '@modules/users/entities/user.entity';
import { Booking } from '@modules/bookings/entities/booking.entity';

@Module({
  imports: [
    MikroOrmModule.forFeature([ChatMessage, User, Booking]),
    JwtModule.register({}), // Handled by JwtStrategy in AuthModule, but needed for Gateway verification logic
    CacheModule.register({}),
  ],
  controllers: [ChatController],
  providers: [ChatService, ChatGateway, NotificationService],
  exports: [ChatService],
})
export class ChatModule {}
