import {
  Injectable,
  NotFoundException,
  BadRequestException,
} from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Ad, AdStatus, AdType, AdPlacement } from '../entities/ad.entity';
import { AdEvent, AdEventType } from '../entities/ad-event.entity';
import { User } from '../../users/entities/user.entity';

export interface CreateAdDto {
  advertiserId: string;
  title: string;
  description?: string;
  imageUrl: string;
  linkUrl: string;
  adType: AdType;
  placement: AdPlacement;
  startDate: Date;
  endDate?: Date;
  budget: number;
}

export interface AdStats {
  impressions: number;
  clicks: number;
  ctr: number;
  spent: number;
  remainingBudget: number;
}

@Injectable()
export class AdsService {
  constructor(
    @InjectRepository(Ad)
    private adRepository: Repository<Ad>,
    @InjectRepository(AdEvent)
    private adEventRepository: Repository<AdEvent>,
    @InjectRepository(User)
    private userRepository: Repository<User>,
  ) {}

  /**
   * Create a new ad
   */
  async createAd(dto: CreateAdDto): Promise<Ad> {
    const advertiser = await this.userRepository.findOne({
      where: { id: dto.advertiserId },
    });

    if (!advertiser) {
      throw new NotFoundException('Advertiser not found');
    }

    if (dto.endDate && dto.endDate <= dto.startDate) {
      throw new BadRequestException('End date must be after start date');
    }

    const ad = this.adRepository.create({
      ...dto,
      status: AdStatus.ACTIVE,
      spent: 0,
      impressions: 0,
      clicks: 0,
      ctr: 0,
    });

    return this.adRepository.save(ad);
  }

  /**
   * Get active ads for a placement
   */
  async getActiveAds(placement: AdPlacement): Promise<Ad[]> {
    const today = new Date();

    return this.adRepository.find({
      where: {
        placement,
        status: AdStatus.ACTIVE,
      },
      order: { createdAt: 'DESC' },
    });
  }

  /**
   * Record ad impression
   */
  async recordImpression(
    adId: string,
    userId?: string,
    ipAddress?: string,
    userAgent?: string,
  ): Promise<void> {
    const ad = await this.adRepository.findOne({ where: { id: adId } });

    if (!ad) {
      return; // Silently fail for impressions
    }

    // Check if ad is still active and within budget
    if (ad.status !== AdStatus.ACTIVE) {
      return;
    }

    const today = new Date();
    if (ad.startDate > today || (ad.endDate && ad.endDate < today)) {
      return;
    }

    if (ad.spent >= ad.budget) {
      // Pause ad if budget exhausted
      ad.status = AdStatus.PAUSED;
      await this.adRepository.save(ad);
      return;
    }

    // Record impression event
    const event = this.adEventRepository.create({
      adId,
      eventType: AdEventType.IMPRESSION,
      userId,
      ipAddress,
      userAgent,
    });

    await this.adEventRepository.save(event);

    // Update ad stats
    ad.impressions += 1;
    const cpc = 0.5; // Cost per click (configurable)
    const estimatedCost = ad.impressions * (cpc / 100); // Assume 1% CTR
    ad.spent = Math.min(estimatedCost, ad.budget);
    ad.ctr = ad.clicks > 0 ? (ad.clicks / ad.impressions) * 100 : 0;

    await this.adRepository.save(ad);
  }

  /**
   * Record ad click
   */
  async recordClick(
    adId: string,
    userId?: string,
    ipAddress?: string,
    userAgent?: string,
    referrer?: string,
  ): Promise<void> {
    const ad = await this.adRepository.findOne({ where: { id: adId } });

    if (!ad || ad.status !== AdStatus.ACTIVE) {
      return;
    }

    // Record click event
    const event = this.adEventRepository.create({
      adId,
      eventType: AdEventType.CLICK,
      userId,
      ipAddress,
      userAgent,
      referrer,
    });

    await this.adEventRepository.save(event);

    // Update ad stats
    ad.clicks += 1;
    const cpc = 0.5; // Cost per click (configurable)
    ad.spent = Math.min(ad.spent + cpc, ad.budget);
    ad.ctr = (ad.clicks / ad.impressions) * 100;

    // Pause if budget exhausted
    if (ad.spent >= ad.budget) {
      ad.status = AdStatus.PAUSED;
    }

    await this.adRepository.save(ad);
  }

  /**
   * Get ad statistics
   */
  async getAdStats(adId: string): Promise<AdStats> {
    const ad = await this.adRepository.findOne({ where: { id: adId } });

    if (!ad) {
      throw new NotFoundException('Ad not found');
    }

    return {
      impressions: ad.impressions,
      clicks: ad.clicks,
      ctr: ad.ctr,
      spent: ad.spent,
      remainingBudget: ad.budget - ad.spent,
    };
  }

  /**
   * Get ads revenue
   */
  async getAdsRevenue(
    startDate?: Date,
    endDate?: Date,
  ): Promise<{
    totalRevenue: number;
    activeAds: number;
    totalImpressions: number;
    totalClicks: number;
    averageCtr: number;
  }> {
    const query = this.adRepository.createQueryBuilder('ad');

    if (startDate) {
      query.andWhere('ad.createdAt >= :startDate', { startDate });
    }
    if (endDate) {
      query.andWhere('ad.createdAt <= :endDate', { endDate });
    }

    const [ads, totalImpressionsResult, totalClicksResult] = await Promise.all([
      query.getMany(),
      query
        .clone()
        .select('SUM(ad.impressions)', 'total')
        .getRawOne(),
      query
        .clone()
        .select('SUM(ad.clicks)', 'total')
        .getRawOne(),
    ]);

    const totalRevenue = ads.reduce((sum, ad) => sum + ad.spent, 0);
    const activeAds = ads.filter((ad) => ad.status === AdStatus.ACTIVE).length;
    const totalImpressions = parseInt(totalImpressionsResult?.total || '0');
    const totalClicks = parseInt(totalClicksResult?.total || '0');
    const averageCtr =
      totalImpressions > 0 ? (totalClicks / totalImpressions) * 100 : 0;

    return {
      totalRevenue,
      activeAds,
      totalImpressions,
      totalClicks,
      averageCtr: Math.round(averageCtr * 100) / 100,
    };
  }

  /**
   * Update ad status
   */
  async updateAdStatus(
    adId: string,
    status: AdStatus,
  ): Promise<Ad> {
    const ad = await this.adRepository.findOne({ where: { id: adId } });

    if (!ad) {
      throw new NotFoundException('Ad not found');
    }

    ad.status = status;
    return this.adRepository.save(ad);
  }

  /**
   * Get advertiser's ads
   */
  async getAdvertiserAds(advertiserId: string): Promise<Ad[]> {
    return this.adRepository.find({
      where: { advertiser: { id: advertiserId } },
      order: { createdAt: 'DESC' },
    });
  }
}
