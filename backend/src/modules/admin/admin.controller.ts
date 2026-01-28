import {
  Controller,
  Get,
  Put,
  Param,
  Query,
  UseGuards,
} from '@nestjs/common';
import { ApiTags, ApiOperation, ApiBearerAuth } from '@nestjs/swagger';
import { AdminService } from './admin.service';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { RolesGuard } from '../auth/guards/roles.guard';
import { Roles } from '../auth/decorators/roles.decorator';
import { UserRole } from '../../../common/enums/user-role.enum';

@ApiTags('admin')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard, RolesGuard)
@Roles(UserRole.ADMIN)
@Controller('admin')
export class AdminController {
  constructor(private readonly adminService: AdminService) {}

  @Get('dashboard')
  @ApiOperation({ summary: 'Get dashboard statistics' })
  async getDashboard() {
    return this.adminService.getDashboardStats();
  }

  @Get('users')
  @ApiOperation({ summary: 'Get all users' })
  async getAllUsers(
    @Query('page') page?: number,
    @Query('limit') limit?: number,
  ) {
    return this.adminService.getAllUsers(page, limit);
  }

  @Get('vehicles')
  @ApiOperation({ summary: 'Get all vehicles' })
  async getAllVehicles(
    @Query('page') page?: number,
    @Query('limit') limit?: number,
  ) {
    return this.adminService.getAllVehicles(page, limit);
  }

  @Put('vehicles/:id/approve')
  @ApiOperation({ summary: 'Approve a vehicle' })
  async approveVehicle(@Param('id') id: string) {
    return this.adminService.approveVehicle(id);
  }

  @Put('vehicles/:id/reject')
  @ApiOperation({ summary: 'Reject a vehicle' })
  async rejectVehicle(
    @Param('id') id: string,
    @Query('reason') reason?: string,
  ) {
    return this.adminService.rejectVehicle(id, reason);
  }

  @Put('drivers/:id/verify')
  @ApiOperation({ summary: 'Verify a driver' })
  async verifyDriver(@Param('id') id: string) {
    return this.adminService.verifyDriver(id);
  }
}
