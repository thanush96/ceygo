import { Test, TestingModule } from '@nestjs/testing';
import { PayHereService } from './payhere.service';
import { ConfigService } from '@nestjs/config';
import * as crypto from 'crypto';

describe('PayHereService', () => {
  let service: PayHereService;
  let configService: ConfigService;

  const mockConfigService = {
    get: jest.fn((key: string) => {
      if (key === 'PAYHERE_MERCHANT_ID') return '12345';
      if (key === 'PAYHERE_SECRET') return 'secret';
      if (key === 'PAYHERE_SANDBOX') return true;
      return null;
    }),
  };

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [
        PayHereService,
        { provide: ConfigService, useValue: mockConfigService },
      ],
    }).compile();

    service = module.get<PayHereService>(PayHereService);
    configService = module.get<ConfigService>(ConfigService);
  });

  it('should be defined', () => {
    expect(service).toBeDefined();
  });

  describe('generatePaymentLink', () => {
    it('should generate a valid payment link with correct hash', () => {
      const params = {
        orderId: 'ORD001',
        items: 'Test Item',
        amount: 5000,
        currency: 'LKR',
        firstName: 'John',
        lastName: 'Doe',
        email: 'john@example.com',
        phone: '0771234567',
        address: 'Addr',
        city: 'Col',
        country: 'SL',
      };

      const url = service.generatePaymentLink(params);
      expect(url).toContain('sandbox.payhere.lk');
      expect(url).toContain('merchant_id=12345');
      expect(url).toContain('order_id=ORD001');
      expect(url).toContain('hash=');
    });
  });

  describe('verifySignature', () => {
    it('should verify correct signature from PayHere notify', () => {
      const merchantId = '12345';
      const orderId = 'ORD001';
      const amount = '5000.00';
      const currency = 'LKR';
      const statusCode = '2';
      const secret = 'secret';

      const hashedSecret = crypto.createHash('md5').update(secret).digest('hex').toUpperCase();
      const sigRaw = merchantId + orderId + amount + currency + statusCode + hashedSecret;
      const md5sig = crypto.createHash('md5').update(sigRaw).digest('hex').toUpperCase();

      const notifyDto = {
        order_id: orderId,
        payment_id: 'PAY001',
        payhere_amount: amount,
        payhere_currency: currency,
        status_code: statusCode,
        md5sig,
      };

      expect(service.verifySignature(notifyDto)).toBe(true);
    });

    it('should return false for invalid signature', () => {
      const notifyDto = {
        order_id: 'ORD001',
        payment_id: 'PAY001',
        payhere_amount: '5000.00',
        payhere_currency: 'LKR',
        status_code: '2',
        md5sig: 'INVALID',
      };

      expect(service.verifySignature(notifyDto)).toBe(false);
    });
  });
});
