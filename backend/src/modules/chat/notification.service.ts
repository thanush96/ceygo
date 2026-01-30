import { Injectable, OnModuleInit, Logger } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import * as admin from 'firebase-admin';

@Injectable()
export class NotificationService implements OnModuleInit {
  private readonly logger = new Logger(NotificationService.name);

  constructor(private configService: ConfigService) {}

  onModuleInit() {
    const projectId = this.configService.get<string>('FIREBASE_PROJECT_ID');
    const privateKey = this.configService.get<string>('FIREBASE_PRIVATE_KEY')?.replace(/\\n/g, '\n');
    const clientEmail = this.configService.get<string>('FIREBASE_CLIENT_EMAIL');

    if (projectId && privateKey && clientEmail) {
      if (!admin.apps.length) {
        admin.initializeApp({
          credential: admin.credential.cert({
            projectId,
            privateKey,
            clientEmail,
          }),
        });
        this.logger.log('Firebase Admin SDK initialized successfully');
      }
    } else {
      this.logger.warn('Firebase credentials missing. Push notifications will be disabled.');
    }
  }

  async sendPushNotification(userId: string, title: string, body: string, data?: any) {
    // In a real app, you would fetch FCM tokens for this userId from the database
    // For now, we simulate the structure
    this.logger.log(`Simulating push notification for user ${userId}: ${title} - ${body}`);
    
    if (!admin.apps.length) return;

    // Placeholder for actual device tokens fetch
    const tokens: string[] = []; // await this.userRepository.getFcmTokens(userId);

    if (tokens.length === 0) return;

    const message = {
      notification: { title, body },
      data: data || {},
      tokens,
    };

    try {
      const response = await admin.messaging().sendEachForMulticast(message);
      this.logger.log(`Successfully sent ${response.successCount} push notifications`);
    } catch (error) {
      this.logger.error('Error sending push notification:', error);
    }
  }
}
