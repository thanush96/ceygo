import { Process, Processor } from '@nestjs/bull';
import { Job } from 'bull';
import { Logger } from '@nestjs/common';

@Processor('notifications')
export class NotificationProcessor {
  private readonly logger = new Logger(NotificationProcessor.name);

  @Process('send')
  async handleSendNotification(job: Job<any>) {
    this.logger.debug('Start processing notification...');
    const { userId, type, message } = job.data;
    
    // In a real app, integrate with Notify.lk or Firebase FCM here
    // For now, we simulate async processing
    await new Promise(resolve => setTimeout(resolve, 100)); // Simulate delay
    
    this.logger.log(`[Notification] To User ${userId}: [${type}] ${message}`);
    this.logger.debug('Notification sent successfully.');
  }
}
