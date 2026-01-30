import { Injectable, OnModuleInit, Logger } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import * as admin from 'firebase-admin';

@Injectable()
export class NotificationService implements OnModuleInit {
  private readonly logger = new Logger(NotificationService.name);

  constructor(private configService: ConfigService) {}

  onModuleInit() {
    const projectId = this.configService.get<string>('FIREBASE_PROJECT_ID');
    let privateKey = this.configService.get<string>('FIREBASE_PRIVATE_KEY');
    
    // Advanced private key sanitization
    if (privateKey) {
      // 1. Handle common copy-paste artifacts like surrounding quotes
      privateKey = privateKey.trim();
      if (privateKey.startsWith('"') && privateKey.endsWith('"')) {
        privateKey = privateKey.slice(1, -1);
      }
      if (privateKey.startsWith("'") && privateKey.endsWith("'")) {
        privateKey = privateKey.slice(1, -1);
      }

      // 2. Handle escaped newlines (common in .env)
      privateKey = privateKey.replace(/\\n/g, '\n');

      // 3. Ensure correct PEM format using Regex reconstruction if needed
      // This helps if spaces were used instead of newlines or if headers are fused
      const pemRegex = /(-+BEGIN PRIVATE KEY-+)([\s\S]*?)(-+END PRIVATE KEY-+)/;
      const match = privateKey.match(pemRegex);
      
      if (match) {
        const header = match[1];
        const body = match[2].replace(/\s/g, ''); // Remove all whitespace from body to clean it
        const footer = match[3];
        
        // Reformat body into 64-char lines (standard PEM) or just ensure strict single block
        // Firebase Admin SDK (forge) is usually fine with one big block if headers are separate
        // But let's separate header and footer clearly
        privateKey = `${header}\n${body}\n${footer}`;
      }
    }
    
    const clientEmail = this.configService.get<string>('FIREBASE_CLIENT_EMAIL');

    if (projectId && privateKey && clientEmail) {
      if (!admin.apps.length) {
        try {
          admin.initializeApp({
            credential: admin.credential.cert({
              projectId,
              privateKey,
              clientEmail,
            }),
          });
          this.logger.log('Firebase Admin SDK initialized successfully');
        } catch (error) {
          this.logger.error('Failed to initialize Firebase Admin SDK', error.stack);
          // Safe logging for debug
          const safeKey = privateKey ? `${privateKey.substring(0, 30)}...[length=${privateKey.length}]` : 'undefined';
          this.logger.error(`Private Key Debug: ${safeKey}`);
          
          if (privateKey?.includes('your_firebase_private_key')) {
             this.logger.error('CRITICAL: You are using the placeholder private key. Please update .env with the real key from your Firebase service account JSON.');
          }
           this.logger.error(`Key contains newlines: ${privateKey?.includes('\n')}`);
        }
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
