import { Injectable, ForbiddenException, NotFoundException, Inject } from '@nestjs/common';
import { InjectRepository } from '@mikro-orm/nestjs';
import { EntityRepository, EntityManager } from '@mikro-orm/postgresql';
import { CACHE_MANAGER } from '@nestjs/cache-manager';
import { Cache } from 'cache-manager';
import { ChatMessage } from './entities/chat-message.entity';
import { User } from '@modules/users/entities/user.entity';
import { Booking } from '@modules/bookings/entities/booking.entity';
import { NotificationService } from './notification.service';

@Injectable()
export class ChatService {
  constructor(
    @InjectRepository(ChatMessage)
    private readonly messageRepository: EntityRepository<ChatMessage>,
    @InjectRepository(User)
    private readonly userRepository: EntityRepository<User>,
    @InjectRepository(Booking)
    private readonly bookingRepository: EntityRepository<Booking>,
    private readonly em: EntityManager,
    private readonly notificationService: NotificationService,
    @Inject(CACHE_MANAGER) private cacheManager: Cache,
  ) {}

  async canChat(userId1: string, userId2: string): Promise<boolean> {
    // Only allow chat if there is an active/upcoming booking between them
    const booking = await this.bookingRepository.findOne({
      $or: [
        { renter: userId1, vehicle: { owner: userId2 } },
        { renter: userId2, vehicle: { owner: userId1 } },
      ],
      status: { $in: ['pending', 'confirmed', 'paid'] },
    });

    return !!booking;
  }

  async sendMessage(senderId: string, receiverId: string, message: string) {
    if (!(await this.canChat(senderId, receiverId))) {
      throw new ForbiddenException('You can only chat with users you have an active booking with');
    }

    const sender = await this.userRepository.findOne({ id: senderId });
    const receiver = await this.userRepository.findOne({ id: receiverId });

    if (!sender || !receiver) {
      throw new NotFoundException('User not found');
    }

    const chatMessage = this.messageRepository.create({
      sender: sender.id,
      receiver: receiver.id,
      message,
    });

    await this.em.persistAndFlush(chatMessage);

    // Check online status in Redis
    const isOnline = await this.cacheManager.get<boolean>(`user:${receiverId}:online`);
    if (!isOnline) {
      await this.notificationService.sendPushNotification(
        receiverId,
        `New message from ${sender.name}`,
        message,
        { senderId, type: 'chat' }
      );
    }

    return chatMessage;
  }

  async getConversation(userId1: string, userId2: string, page = 1, limit = 50) {
    const [items, total] = await this.messageRepository.findAndCount(
      {
        $or: [
          { sender: userId1, receiver: userId2 },
          { sender: userId2, receiver: userId1 },
        ],
      },
      {
        limit,
        offset: (page - 1) * limit,
        orderBy: { timestamp: 'DESC' },
        populate: ['sender', 'receiver'] as any,
      }
    );

    return {
      items: items.reverse(), // Traditional chat order
      meta: {
        total,
        page,
        limit,
      },
    };
  }

  async getConversations(userId: string) {
    // This is a simplified fetch - normally you'd use a more complex aggregate query
    // or a dedicated 'Conversation' entity for performance.
    const messages = await this.messageRepository.find(
      { $or: [{ sender: userId }, { receiver: userId }] },
      { populate: ['sender', 'receiver'] as any, orderBy: { timestamp: 'DESC' } }
    );

    const conversationsMap = new Map();
    messages.forEach((msg) => {
      const otherUser = msg.sender.id === userId ? msg.receiver : msg.sender;
      if (!conversationsMap.has(otherUser.id)) {
        conversationsMap.set(otherUser.id, {
          user: otherUser,
          lastMessage: msg,
        });
      }
    });

    return Array.from(conversationsMap.values());
  }

  async markAsRead(receiverId: string, senderId: string) {
    const qb = this.em.createQueryBuilder(ChatMessage);
    await qb
      .update({ isRead: true })
      .where({ receiver: receiverId, sender: senderId, isRead: false })
      .execute();
  }

  async getUnreadCount(userId: string) {
    return this.messageRepository.count({ receiver: userId, isRead: false });
  }

  async setUserOnline(userId: string, online: boolean) {
    if (online) {
      await this.cacheManager.set(`user:${userId}:online`, true, 300000); // 5 min TTL
    } else {
      await this.cacheManager.del(`user:${userId}:online`);
    }
  }
}
