import { Controller, Get, Post, Body, Param, Query, UseGuards, Request } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiResponse, ApiBearerAuth, ApiBody } from '@nestjs/swagger';
import { ChatService } from './chat.service';
import { JwtAuthGuard } from '@modules/auth/guards/jwt-auth.guard';

@ApiTags('Chat')
@Controller('chat')
@UseGuards(JwtAuthGuard)
@ApiBearerAuth()
export class ChatController {
  constructor(private readonly chatService: ChatService) {}

  @Get('conversations')
  @ApiOperation({ summary: 'Get list of conversations' })
  @ApiResponse({ status: 200, description: 'List of conversations' })
  getConversations(@Request() req) {
    return this.chatService.getConversations(req.user.id);
  }

  @Get(':userId/messages')
  @ApiOperation({ summary: 'Get messages with a specific user' })
  @ApiResponse({ status: 200, description: 'Paginated list of messages' })
  getMessages(
    @Request() req,
    @Param('userId') userId: string,
    @Query('page') page: number,
  ) {
    return this.chatService.getConversation(req.user.id, userId, page);
  }

  @Get('unread')
  @ApiOperation({ summary: 'Get total unread message count' })
  @ApiResponse({ status: 200, description: 'Unread count returned' })
  getUnreadCount(@Request() req) {
    return this.chatService.getUnreadCount(req.user.id);
  }

  @Post('messages')
  @ApiOperation({ summary: 'Send a new message' })
  @ApiResponse({ status: 201, description: 'Message sent successfully' })
  @ApiBody({ schema: { type: 'object', example: { receiverId: 'uuid', message: 'Hello' } } })
  sendMessage(
    @Request() req,
    @Body() body: { receiverId: string; message: string },
  ) {
    return this.chatService.sendMessage(req.user.id, body.receiverId, body.message);
  }

  @Post('read/:senderId')
  @ApiOperation({ summary: 'Mark messages as read from a sender' })
  @ApiResponse({ status: 200, description: 'Messages marked as read' })
  markAsRead(@Request() req, @Param('senderId') senderId: string) {
    return this.chatService.markAsRead(req.user.id, senderId);
  }
}
