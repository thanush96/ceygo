import { Controller, Get, Post, Body, Param, Query, UseGuards, Request } from '@nestjs/common';
import { ChatService } from './chat.service';
import { JwtAuthGuard } from '@modules/auth/guards/jwt-auth.guard';

@Controller('chat')
@UseGuards(JwtAuthGuard)
export class ChatController {
  constructor(private readonly chatService: ChatService) {}

  @Get('conversations')
  getConversations(@Request() req) {
    return this.chatService.getConversations(req.user.id);
  }

  @Get(':userId/messages')
  getMessages(
    @Request() req,
    @Param('userId') userId: string,
    @Query('page') page: number,
  ) {
    return this.chatService.getConversation(req.user.id, userId, page);
  }

  @Get('unread')
  getUnreadCount(@Request() req) {
    return this.chatService.getUnreadCount(req.user.id);
  }

  @Post('messages')
  sendMessage(
    @Request() req,
    @Body() body: { receiverId: string; message: string },
  ) {
    return this.chatService.sendMessage(req.user.id, body.receiverId, body.message);
  }

  @Post('read/:senderId')
  markAsRead(@Request() req, @Param('senderId') senderId: string) {
    return this.chatService.markAsRead(req.user.id, senderId);
  }
}
