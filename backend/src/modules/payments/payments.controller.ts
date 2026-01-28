import {
  Controller,
  Post,
  Put,
  Get,
  Param,
  Body,
  Query,
  UseGuards,
} from '@nestjs/common';
import { ApiTags, ApiOperation, ApiBearerAuth } from '@nestjs/swagger';
import { PaymentsService } from './payments.service';
import { BnplService } from './services/bnpl.service';
import { EmiService } from './services/emi.service';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { RolesGuard } from '../auth/guards/roles.guard';
import { Roles } from '../auth/decorators/roles.decorator';
import { CurrentUser } from '../auth/decorators/current-user.decorator';
import { User } from '../users/entities/user.entity';
import { ProcessPaymentDto } from './dto/process-payment.dto';
import { InitiateBnplDto } from './dto/initiate-bnpl.dto';
import { InitiateEmiDto } from './dto/initiate-emi.dto';
import { CalculateEmiDto } from './dto/calculate-emi.dto';
import { UserRole } from '../../../common/enums/user-role.enum';

@ApiTags('payments')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard)
@Controller('payments')
export class PaymentsController {
  constructor(
    private readonly paymentsService: PaymentsService,
    private readonly bnplService: BnplService,
    private readonly emiService: EmiService,
  ) {}

  @Post('process')
  @ApiOperation({ summary: 'Process payment for a booking' })
  async processPayment(
    @CurrentUser() user: User,
    @Body() dto: ProcessPaymentDto,
  ) {
    return this.paymentsService.processPayment(user.id, dto);
  }

  @Post('bnpl/check-eligibility')
  @ApiOperation({ summary: 'Check BNPL eligibility' })
  async checkBnplEligibility(
    @CurrentUser() user: User,
    @Query('amount') amount: number,
  ) {
    return this.bnplService.checkEligibility(user.id, amount);
  }

  @Post('bnpl/initiate')
  @ApiOperation({ summary: 'Initiate BNPL payment' })
  async initiateBnpl(
    @CurrentUser() user: User,
    @Body() dto: InitiateBnplDto,
  ) {
    return this.paymentsService.processBnplPayment(
      user.id,
      dto.bookingId,
      dto.installmentCount,
      dto.provider,
    );
  }

  @Get('bnpl/plans')
  @ApiOperation({ summary: 'Get user BNPL plans' })
  async getUserBnplPlans(@CurrentUser() user: User) {
    return this.bnplService.getUserPlans(user.id);
  }

  @Get('bnpl/plans/:id')
  @ApiOperation({ summary: 'Get BNPL plan details' })
  async getBnplPlan(@Param('id') id: string) {
    return this.bnplService.getPlan(id);
  }

  @Post('emi/check-eligibility')
  @ApiOperation({ summary: 'Check EMI eligibility' })
  async checkEmiEligibility(
    @CurrentUser() user: User,
    @Query('amount') amount: number,
  ) {
    return this.emiService.checkEligibility(user.id, amount);
  }

  @Post('emi/calculate')
  @ApiOperation({ summary: 'Calculate EMI' })
  async calculateEmi(@Body() dto: CalculateEmiDto) {
    return this.emiService.calculateEmi(
      dto.amount,
      // Get interest rate from bank
      this.emiService.getAvailableBanks().find((b) => b.bankName === dto.bankName)
        ?.interestRate || 12,
      dto.tenureMonths,
    );
  }

  @Post('emi/initiate')
  @ApiOperation({ summary: 'Initiate EMI payment' })
  async initiateEmi(
    @CurrentUser() user: User,
    @Body() dto: InitiateEmiDto,
  ) {
    return this.paymentsService.processEmiPayment(
      user.id,
      dto.bookingId,
      dto.bankName,
      dto.tenureMonths,
    );
  }

  @Get('emi/plans')
  @ApiOperation({ summary: 'Get user EMI plans' })
  async getUserEmiPlans(@CurrentUser() user: User) {
    return this.emiService.getUserPlans(user.id);
  }

  @Get('emi/plans/:id')
  @ApiOperation({ summary: 'Get EMI plan details' })
  async getEmiPlan(@Param('id') id: string) {
    return this.emiService.getPlan(id);
  }

  @Get(':id')
  @ApiOperation({ summary: 'Get payment details' })
  async getPayment(@Param('id') id: string, @CurrentUser() user: User) {
    const payment = await this.paymentsService.findOne(id);
    // Verify user owns the booking
    if (payment.booking.userId !== user.id && user.role !== UserRole.ADMIN) {
      throw new Error('Unauthorized');
    }
    return payment;
  }

  @Put(':id/refund')
  @UseGuards(RolesGuard)
  @Roles(UserRole.ADMIN)
  @ApiOperation({ summary: 'Refund a payment (Admin only)' })
  async refund(
    @Param('id') id: string,
    @Body('amount') amount?: number,
  ) {
    return this.paymentsService.refund(id, amount);
  }
}
