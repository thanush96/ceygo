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
    // Notify.lk expects phone in 9477xxxxxxx format
    const formattedPhone = phone.replace(/^0/, '94').replace(/^\+/, '');
    
    const message = `Your CeyGo verification code is: ${otp}. Valid for 5 minutes.`;

    try {
      // In development, if no API key is provided, just log it
      if (!this.apiKey || this.apiKey === 'your_notify_api_key') {
        console.log(`[DEV] OTP for ${formattedPhone}: ${otp}`);
        return true;
      }

      const response = await axios.get('https://app.notify.lk/api/v1/send', {
        params: {
          user_id: this.userId,
          api_key: this.apiKey,
          sender_id: this.senderId,
          to: formattedPhone,
          message: message,
        },
      });

      return response.data?.status === 'success';
    } catch (error) {
      console.error('Notify.lk API error:', error.response?.data || error.message);
      // In dev, don't block the flow
      if (this.configService.get('NODE_ENV') === 'development') {
        return true;
      }
      throw new InternalServerErrorException('Failed to send OTP');
    }
  }

  generateOtp(): string {
    const length = this.configService.get<number>('OTP_LENGTH') || 6;
    return Math.floor(Math.pow(10, length - 1) + Math.random() * 9 * Math.pow(10, length - 1)).toString();
  }
}
