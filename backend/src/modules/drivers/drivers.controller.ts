import {
  Controller,
  Get,
  Post,
  Put,
  Body,
  UseGuards,
} from '@nestjs/common';
import { ApiTags, ApiOperation, ApiBearerAuth } from '@nestjs/swagger';
import { DriversService } from './drivers.service';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { RolesGuard } from '../auth/guards/roles.guard';
import { Roles } from '../auth/decorators/roles.decorator';
import { CurrentUser } from '../auth/decorators/current-user.decorator';
import { User } from '../users/entities/user.entity';
import { CreateDriverDto } from './dto/create-driver.dto';
import { UserRole } from '../../../common/enums/user-role.enum';

@ApiTags('drivers')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard)
@Controller('drivers')
export class DriversController {
  constructor(private readonly driversService: DriversService) {}

  @Post('register')
  @ApiOperation({ summary: 'Register as driver/owner' })
  async register(
    @CurrentUser() user: User,
    @Body() dto: CreateDriverDto,
  ) {
    return this.driversService.create(user.id, dto);
  }

  @Get('profile')
  @ApiOperation({ summary: 'Get driver profile' })
  async getProfile(@CurrentUser() user: User) {
    return this.driversService.findByUserId(user.id);
  }

  @Put('profile')
  @ApiOperation({ summary: 'Update driver profile' })
  async updateProfile(
    @CurrentUser() user: User,
    @Body() dto: Partial<CreateDriverDto>,
  ) {
    return this.driversService.update(user.id, dto);
  }
}
