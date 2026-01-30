import {
  WebSocketGateway,
  WebSocketServer,
  SubscribeMessage,
  OnGatewayConnection,
  OnGatewayDisconnect,
  MessageBody,
  ConnectedSocket,
} from '@nestjs/websockets';
import { Server, Socket } from 'socket.io';
import { UseGuards, Logger } from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import { ConfigService } from '@nestjs/config';
import { ChatService } from './chat.service';

@WebSocketGateway({
  cors: {
    origin: '*',
  },
})
export class ChatGateway implements OnGatewayConnection, OnGatewayDisconnect {
  @WebSocketServer()
  server: Server;

  private readonly logger = new Logger(ChatGateway.name);

  constructor(
    private readonly chatService: ChatService,
    private readonly jwtService: JwtService,
    private readonly configService: ConfigService,
  ) {}

  async handleConnection(client: Socket) {
    try {
      const token = client.handshake.auth.token || client.handshake.headers.authorization?.split(' ')[1];
      if (!token) {
        client.disconnect();
        return;
      }

      const payload = this.jwtService.verify(token, {
        secret: this.configService.get('JWT_SECRET'),
      });

      const userId = payload.sub;
      client.data.userId = userId;

      // Join personal room
      client.join(`chat_${userId}`);
      
      // Set online status in Redis
      await this.chatService.setUserOnline(userId, true);
      
      this.logger.log(`User connected: ${userId} (${client.id})`);
    } catch (e) {
      this.logger.error(`Connection failed: ${e.message}`);
      client.disconnect();
    }
  }

  async handleDisconnect(client: Socket) {
    const userId = client.data.userId;
    if (userId) {
      await this.chatService.setUserOnline(userId, false);
      this.logger.log(`User disconnected: ${userId} (${client.id})`);
    }
  }

  @SubscribeMessage('send_message')
  async handleMessage(
    @ConnectedSocket() client: Socket,
    @MessageBody() data: { receiverId: string; message: string },
  ) {
    const senderId = client.data.userId;
    if (!senderId) return;

    try {
      const chatMessage = await this.chatService.sendMessage(
        senderId,
        data.receiverId,
        data.message,
      );

      // Emit to recipient
      this.server.to(`chat_${data.receiverId}`).emit('receive_message', chatMessage);
      
      // Emit back to sender (for multi-device sync)
      this.server.to(`chat_${senderId}`).emit('receive_message', chatMessage);
      
      return chatMessage;
    } catch (error) {
      client.emit('error', { message: error.message });
    }
  }
}
