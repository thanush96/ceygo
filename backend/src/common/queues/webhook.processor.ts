import { Process, Processor } from '@nestjs/bull';
import { Job } from 'bull';
import { Logger } from '@nestjs/common';

@Processor('webhooks')
export class WebhookProcessor {
  private readonly logger = new Logger(WebhookProcessor.name);

  @Process('payment_update')
  async handlePaymentUpdate(job: Job<any>) {
    this.logger.debug('Processing payment webhook...');
    const { paymentId, status } = job.data;
    
    // Simulate complex background logic (e.g. updating analytics, notifying external systems)
    await new Promise(resolve => setTimeout(resolve, 50));
    
    this.logger.log(`[Webhook] Payment ${paymentId} status updated to ${status}`);
  }
}
