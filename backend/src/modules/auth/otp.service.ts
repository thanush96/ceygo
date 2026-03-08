import { Injectable, InternalServerErrorException } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import axios from 'axios';

@Injectable()
export class OtpService {
  private readonly apiKey: string;
  private readonly userId: string;
  private readonly senderId: string;

  constructor(private configService: ConfigService) {
    this.apiKey = this.configService.get<string>('NOTIFY_API_KEY');
    this.userId = this.configService.get<string>('NOTIFY_USER_ID');
    this.senderId = this.configService.get<string>('NOTIFY_SENDER_ID') || 'NotifyLK';
  }

  async sendOtp(phone: string, otp: string): Promise<boolean> {
    // Notify.lk expects phone in 9477xxxxxxx format (no + prefix)
    const formattedPhone = phone.replace(/^0/, '94').replace(/^\+/, '');

    const message = `Your CeyGo verification code is: ${otp}. Valid for 5 minutes.`;

    // If no real API key configured, log OTP to console (dev mode)
    if (!this.apiKey || this.apiKey === 'your_notify_api_key') {
      console.log(`[DEV] OTP for ${formattedPhone}: ${otp}`);
      return true;
    }

    try {
      console.log(`[OTP] Sending to ${formattedPhone}...`);

      const response = await axios.get('https://app.notify.lk/api/v1/send', {
        params: {
          user_id: this.userId,
          api_key: this.apiKey,
          sender_id: this.senderId,
          to: formattedPhone,
          message: message,
        },
      });

      const data = response.data;
      console.log(`[OTP] Notify.lk response:`, JSON.stringify(data));

      // Notify.lk returns { status: 'success' } or status code 200 on success
      if (data?.status === 'success' || response.status === 200) {
        return true;
      }

      console.error(`[OTP] Unexpected response:`, data);
      return false;
    } catch (error) {
      console.error('[OTP] Notify.lk API error:', error.response?.data || error.message);
      throw new InternalServerErrorException('Failed to send OTP. Please try again.');
    }
  }

  generateOtp(): string {
    const length = this.configService.get<number>('OTP_LENGTH') || 6;
    return Math.floor(Math.pow(10, length - 1) + Math.random() * 9 * Math.pow(10, length - 1)).toString();
  }
}
