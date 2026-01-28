import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { PricingRule } from '../entities/pricing-rule.entity';

export enum RuleType {
  COMMISSION = 'commission',
  PLATFORM_FEE = 'platform_fee',
  DISCOUNT = 'discount',
  SURCHARGE = 'surcharge',
}

export enum TargetType {
  ALL = 'all',
  CITY = 'city',
  VEHICLE_TYPE = 'vehicle_type',
  USER_TIER = 'user_tier',
}

export enum ValueType {
  PERCENTAGE = 'percentage',
  FIXED = 'fixed',
}

@Injectable()
export class PricingRulesService {
  constructor(
    @InjectRepository(PricingRule)
    private pricingRuleRepository: Repository<PricingRule>,
  ) {}

  /**
   * Get active pricing rule for a specific type and target
   */
  async getActiveRule(
    ruleType: RuleType,
    city?: string,
    driverId?: string,
    vehicleType?: string,
    userTier?: string,
  ): Promise<PricingRule | null> {
    const today = new Date();

    const query = this.pricingRuleRepository
      .createQueryBuilder('rule')
      .where('rule.ruleType = :ruleType', { ruleType })
      .andWhere('rule.isActive = :isActive', { isActive: true })
      .andWhere('(rule.startDate IS NULL OR rule.startDate <= :today)', {
        today,
      })
      .andWhere('(rule.endDate IS NULL OR rule.endDate >= :today)', {
        today,
      })
      .orderBy('rule.priority', 'DESC')
      .addOrderBy('rule.createdAt', 'DESC');

    // Apply target filters
    if (city) {
      query.andWhere(
        '(rule.targetType = :allType OR (rule.targetType = :cityType AND rule.targetValue = :city))',
        {
          allType: TargetType.ALL,
          cityType: TargetType.CITY,
          city,
        },
      );
    }

    if (vehicleType) {
      query.andWhere(
        '(rule.targetType = :allType OR (rule.targetType = :vehicleType AND rule.targetValue = :vehicleTypeValue))',
        {
          allType: TargetType.ALL,
          vehicleType: TargetType.VEHICLE_TYPE,
          vehicleTypeValue: vehicleType,
        },
      );
    }

    if (userTier) {
      query.andWhere(
        '(rule.targetType = :allType OR (rule.targetType = :userTierType AND rule.targetValue = :userTierValue))',
        {
          allType: TargetType.ALL,
          userTierType: TargetType.USER_TIER,
          userTierValue: userTier,
        },
      );
    }

    return query.getOne();
  }

  /**
   * Create a new pricing rule
   */
  async createRule(rule: Partial<PricingRule>): Promise<PricingRule> {
    const newRule = this.pricingRuleRepository.create(rule);
    return this.pricingRuleRepository.save(newRule);
  }

  /**
   * Update a pricing rule
   */
  async updateRule(
    ruleId: string,
    updates: Partial<PricingRule>,
  ): Promise<PricingRule> {
    await this.pricingRuleRepository.update(ruleId, updates);
    return this.pricingRuleRepository.findOne({ where: { id: ruleId } });
  }

  /**
   * Get all active pricing rules
   */
  async getAllActiveRules(): Promise<PricingRule[]> {
    const today = new Date();

    return this.pricingRuleRepository.find({
      where: {
        isActive: true,
      },
      order: {
        priority: 'DESC',
        createdAt: 'DESC',
      },
    });
  }

  /**
   * Deactivate a pricing rule
   */
  async deactivateRule(ruleId: string): Promise<void> {
    await this.pricingRuleRepository.update(ruleId, { isActive: false });
  }
}
