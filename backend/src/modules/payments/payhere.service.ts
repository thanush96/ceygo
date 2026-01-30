import { Injectable } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import axios from 'axios';
import * as crypto from 'crypto';

@Injectable()
export class PayHereService {
  constructor(private configService: ConfigService) {}

  generatePaymentLink(params: {
    orderId: string;
    items: string;
    amount: number;
    currency: string;
    firstName: string;
    lastName: string;
    email: string;
    phone: string;
    address: string;
    city: string;
    country: string;
  }) {
    const merchantId = this.configService.get<string>('PAYHERE_MERCHANT_ID');
    const merchantSecret = this.configService.get<string>('PAYHERE_SECRET');
    const isSandbox = this.configService.get<boolean>('PAYHERE_SANDBOX');
    
    const hashedSecret = crypto
      .createHash('md5')
      .update(merchantSecret)
      .digest('hex')
      .toUpperCase();

    const amountFormatted = params.amount.toLocaleString('en-us', { minimumFractionDigits: 2 }).replaceAll(',', '');
    
    const hash = crypto
      .createHash('md5')
      .update(merchantId + params.orderId + amountFormatted + params.currency + hashedSecret)
      .digest('hex')
      .toUpperCase();

    const baseUrl = isSandbox
      ? 'https://sandbox.payhere.lk/pay/checkout'
      : 'https://www.payhere.lk/pay/checkout';

    const url = new URL(baseUrl);
    url.searchParams.append('merchant_id', merchantId);
    url.searchParams.append('return_url', 'http://sample.com/return'); // These should be from config ideally
    url.searchParams.append('cancel_url', 'http://sample.com/cancel');
    url.searchParams.append('notify_url', 'http://sample.com/notify');
    url.searchParams.append('order_id', params.orderId);
    url.searchParams.append('items', params.items);
    url.searchParams.append('currency', params.currency);
    url.searchParams.append('amount', amountFormatted);
    url.searchParams.append('first_name', params.firstName);
    url.searchParams.append('last_name', params.lastName);
    url.searchParams.append('email', params.email);
    url.searchParams.append('phone', params.phone);
    url.searchParams.append('address', params.address);
    url.searchParams.append('city', params.city);
    url.searchParams.append('country', params.country);
    url.searchParams.append('hash', hash);

    return url.toString();
  }

  async refundPayment(params: {
    paymentId: string;
    amount: number;
    reason?: string;
  }): Promise<boolean> {
    const merchantId = this.configService.get<string>('PAYHERE_MERCHANT_ID');
    const merchantSecret = this.configService.get<string>('PAYHERE_SECRET');
    const isSandbox = this.configService.get<boolean>('PAYHERE_SANDBOX');

    const hashedSecret = crypto
      .createHash('md5')
      .update(merchantSecret)
      .digest('hex')
      .toUpperCase();

    const baseUrl = isSandbox
      ? 'https://sandbox.payhere.lk/merchant/v1/payment/refund'
      : 'https://www.payhere.lk/merchant/v1/payment/refund';

    try {
      const response = await axios.post(
        baseUrl,
        {
          payment_id: params.paymentId,
          amount: params.amount,
          reason: params.reason || 'Customer cancellation',
        },
        {
          headers: {
            Authorization: `Bearer ${hashedSecret}`, // PayHere typically uses a Different auth for Server-to-Server
            'Content-Type': 'application/json',
          },
        },
      );
      return response.data?.status === 1;
    } catch (error) {
      console.error('PayHere Refund Error:', error.response?.data || error.message);
      return false;
    }
  }
}
