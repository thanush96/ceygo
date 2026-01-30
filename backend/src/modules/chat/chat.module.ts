import { Module } from '@nestjs/common';
import { MikroOrmModule } from '@mikro-orm/nestjs';
import { ChatMessage } from './entities/chat-message.entity';

@Module({
  imports: [MikroOrmModule.forFeature([ChatMessage])],
  exports: [MikroOrmModule],
})
export class ChatModule {}
