import {
  Controller,
  Get,
  Post,
  Put,
  Body,
  Param,
  Query,
  UseGuards,
} from '@nestjs/common';
import { ApiTags, ApiOperation, ApiBearerAuth } from '@nestjs/swagger';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { RolesGuard } from '../auth/guards/roles.guard';
import { Roles } from '../auth/decorators/roles.decorator';
import { CurrentUser } from '../auth/decorators/current-user.decorator';
import { User } from '../users/entities/user.entity';
import { UserRole } from '../../common/enums/user-role.enum';
import { CommissionService } from './services/commission.service';
import { PricingRulesService } from './services/pricing-rules.service';
import { SubscriptionsService } from './services/subscriptions.service';
import { AdsService } from './services/ads.service';

@ApiTags('revenue')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard)
@Controller('revenue')
export class RevenueController {
  constructor(
    private readonly commissionService: CommissionService,
    private readonly pricingRulesService: PricingRulesService,
    private readonly subscriptionsService: SubscriptionsService,
    private readonly adsService: AdsService,
  ) {}

  @Get('overview')
  @UseGuards(RolesGuard)
  @Roles(UserRole.ADMIN)
  @ApiOperation({ summary: 'Get revenue overview (Admin only)' })
  async getRevenueOverview(
    @Query('startDate') startDate?: string,
    @Query('endDate') endDate?: string,
  ) {
    const [commission, subscriptions, ads] = await Promise.all([
      this.commissionService.getCommissionSummary(
        startDate ? new Date(startDate) : undefined,
        endDate ? new Date(endDate) : undefined,
      ),
      this.subscriptionsService.getSubscriptionRevenue(
        startDate ? new Date(startDate) : undefined,
        endDate ? new Date(endDate) : undefined,
      ),
      this.adsService.getAdsRevenue(
        startDate ? new Date(startDate) : undefined,
        endDate ? new Date(endDate) : undefined,
      ),
    ]);

    return {
      commission,
      subscriptions,
      ads,
      totalRevenue:
        commission.totalRevenue +
        subscriptions.totalRevenue +
        ads.totalRevenue,
    };
  }

  @Get('commission')
  @UseGuards(RolesGuard)
  @Roles(UserRole.ADMIN)
  @ApiOperation({ summary: 'Get commission summary (Admin only)' })
  async getCommissionSummary(
    @Query('startDate') startDate?: string,
    @Query('endDate') endDate?: string,
    @Query('driverId') driverId?: string,
  ) {
    return this.commissionService.getCommissionSummary(
      startDate ? new Date(startDate) : undefined,
      endDate ? new Date(endDate) : undefined,
      driverId,
    );
  }

  @Get('subscriptions')
  @UseGuards(RolesGuard)
  @Roles(UserRole.ADMIN)
  @ApiOperation({ summary: 'Get subscription revenue (Admin only)' })
  async getSubscriptionRevenue(
    @Query('startDate') startDate?: string,
    @Query('endDate') endDate?: string,
  ) {
    return this.subscriptionsService.getSubscriptionRevenue(
      startDate ? new Date(startDate) : undefined,
      endDate ? new Date(endDate) : undefined,
    );
  }

  @Get('ads')
  @UseGuards(RolesGuard)
  @Roles(UserRole.ADMIN)
  @ApiOperation({ summary: 'Get ads revenue (Admin only)' })
  async getAdsRevenue(
    @Query('startDate') startDate?: string,
    @Query('endDate') endDate?: string,
  ) {
    return this.adsService.getAdsRevenue(
      startDate ? new Date(startDate) : undefined,
      endDate ? new Date(endDate) : undefined,
    );
  }

  @Get('subscriptions/plans')
  @ApiOperation({ summary: 'Get available subscription plans' })
  async getAvailablePlans() {
    return this.subscriptionsService.getAvailablePlans();
  }

  @Post('subscriptions')
  @ApiOperation({ summary: 'Create subscription' })
  async createSubscription(
    @CurrentUser() user: User,
    @Body('planType') planType: string,
    @Body('paymentMethod') paymentMethod: string,
    @Body('autoRenew') autoRenew: boolean = true,
  ) {
    return this.subscriptionsService.createSubscription(
      user.id,
      planType as any,
      paymentMethod,
      autoRenew,
    );
  }

  @Get('subscriptions/my')
  @ApiOperation({ summary: 'Get my subscription' })
  async getMySubscription(@CurrentUser() user: User) {
    return this.subscriptionsService.getUserSubscription(user.id);
  }

  @Put('subscriptions/:id/cancel')
  @ApiOperation({ summary: 'Cancel subscription' })
  async cancelSubscription(
    @Param('id') id: string,
    @CurrentUser() user: User,
  ) {
    const subscription = await this.subscriptionsService.getUserSubscription(
      user.id,
    );
    if (!subscription || subscription.id !== id) {
      throw new Error('Unauthorized');
    }
    return this.subscriptionsService.cancelSubscription(id);
  }

  @Get('pricing-rules')
  @UseGuards(RolesGuard)
  @Roles(UserRole.ADMIN)
  @ApiOperation({ summary: 'Get all pricing rules (Admin only)' })
  async getPricingRules() {
    return this.pricingRulesService.getAllActiveRules();
  }

  @Post('pricing-rules')
  @UseGuards(RolesGuard)
  @Roles(UserRole.ADMIN)
  @ApiOperation({ summary: 'Create pricing rule (Admin only)' })
  async createPricingRule(
    @CurrentUser() user: User,
    @Body() rule: any,
  ) {
    return this.pricingRulesService.createRule({
      ...rule,
      createdBy: user.id,
    });
  }

  @Put('pricing-rules/:id')
  @UseGuards(RolesGuard)
  @Roles(UserRole.ADMIN)
  @ApiOperation({ summary: 'Update pricing rule (Admin only)' })
  async updatePricingRule(
    @Param('id') id: string,
    @Body() updates: any,
  ) {
    return this.pricingRulesService.updateRule(id, updates);
  }

  @Put('pricing-rules/:id/deactivate')
  @UseGuards(RolesGuard)
  @Roles(UserRole.ADMIN)
  @ApiOperation({ summary: 'Deactivate pricing rule (Admin only)' })
  async deactivatePricingRule(@Param('id') id: string) {
    await this.pricingRulesService.deactivateRule(id);
    return { message: 'Pricing rule deactivated' };
  }
}
