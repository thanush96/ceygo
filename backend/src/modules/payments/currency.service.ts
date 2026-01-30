import { Injectable, Inject } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { CACHE_MANAGER } from '@nestjs/cache-manager';
import { Cache } from 'cache-manager';
import axios from 'axios';

@Injectable()
export class CurrencyService {
  private readonly apiUrl = 'https://openexchangerates.org/api/latest.json';

  constructor(
    private configService: ConfigService,
    @Inject(CACHE_MANAGER) private cacheManager: Cache,
  ) {}

  async getLkrToUsdRate(): Promise<number> {
    const cacheKey = 'lkr_usd_rate';
    const cachedRate = await this.cacheManager.get<number>(cacheKey);
    
    if (cachedRate) {
      return cachedRate;
    }

    const appId = this.configService.get<string>('OPEN_EXCHANGE_RATES_APP_ID');
    if (!appId || appId === 'your_app_id') {
      // Fallback rate if API not configured
      return 0.0031; // Approx 1 LKR = 0.0031 USD
    }

    try {
      const response = await axios.get(this.apiUrl, {
        params: {
          app_id: appId,
          base: 'USD',
          symbols: 'LKR',
        },
      });

      const lkrRate = response.data?.rates?.LKR;
      if (!lkrRate) throw new Error('Failed to fetch LKR rate');

      const usdToLkrRate = 1 / lkrRate;
      
      // Cache for 6 hours
      await this.cacheManager.set(cacheKey, usdToLkrRate, 21600000);
      
      return usdToLkrRate;
    } catch (error) {
      console.error('Currency Conversion Error:', error.message);
      return 0.0031; // Fallback
    }
  }

  async convertToUsd(lkrAmount: number): Promise<number> {
    const rate = await this.getLkrToUsdRate();
    return parseFloat((lkrAmount * rate).toFixed(2));
  }
}
