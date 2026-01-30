import { Controller, Get, Post, Patch, Body, Param, Query, UseGuards, Res } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiResponse, ApiBearerAuth } from '@nestjs/swagger';
import { Throttle } from '@nestjs/throttler';
import { Response } from 'express';
import { AdminService } from './admin.service';
import { JwtAuthGuard } from '@modules/auth/guards/jwt-auth.guard';
import { RolesGuard } from '@modules/auth/guards/roles.guard';
import { Roles } from '@common/decorators/roles.decorator';

@ApiTags('Admin')
@Controller('admin')
@UseGuards(JwtAuthGuard, RolesGuard)
@Roles('admin')
@ApiBearerAuth()
@Throttle({ default: { limit: 100, ttl: 60000 } })
export class AdminController {
  constructor(private readonly adminService: AdminService) {}

  @Get('dashboard')
  @ApiOperation({ summary: 'Get admin dashboard stats' })
  getDashboardStats() {
    return this.adminService.getDashboardStats();
  }

  @Get('verifications/pending')
  @ApiOperation({ summary: 'Get pending verifications' })
  getPendingVerifications() {
    return this.adminService.getPendingVerifications();
  }

  @Patch('users/:id/verify')
  @ApiOperation({ summary: 'Verify or reject a user' })
  verifyUser(
    @Param('id') id: string,
    @Body('status') status: string,
    @Body('reason') reason?: string,
  ) {
    return this.adminService.verifyUser(id, status, reason);
  }

  @Patch('vehicles/:id/verify')
  @ApiOperation({ summary: 'Verify or reject a vehicle' })
  verifyVehicle(
    @Param('id') id: string,
    @Body('status') status: string,
    @Body('reason') reason?: string,
  ) {
    return this.adminService.verifyVehicle(id, status, reason);
  }

  @Get('users')
  @ApiOperation({ summary: 'Get all users with filters' })
  getAllUsers(@Query() filters: any) {
    return this.adminService.getAllUsers(filters, filters.page, filters.limit);
  }

  @Patch('users/:id/ban')
  @ApiOperation({ summary: 'Ban a user' })
  banUser(@Param('id') id: string, @Body('reason') reason: string) {
    return this.adminService.banUser(id, reason);
  }

  @Patch('users/:id/unban')
  @ApiOperation({ summary: 'Unban a user' })
  unbanUser(@Param('id') id: string) {
    return this.adminService.unbanUser(id);
  }

  @Get('vehicles')
  @ApiOperation({ summary: 'Get all vehicles with filters' })
  getAllVehicles(@Query() filters: any) {
    return this.adminService.getAllVehicles(filters, filters.page, filters.limit);
  }

  @Patch('vehicles/:id/blacklist')
  @ApiOperation({ summary: 'Blacklist a vehicle' })
  blacklistVehicle(@Param('id') id: string, @Body('reason') reason: string) {
    return this.adminService.blacklistVehicle(id, reason);
  }

  @Get('reports/revenue')
  @ApiOperation({ summary: 'Get revenue reports' })
  getRevenueReport(@Query('start') start: string, @Query('end') end: string) {
    return this.adminService.getRevenueReport(start, end);
  }

  @Get('export/users')
  @ApiOperation({ summary: 'Export users to CSV' })
  async exportUsers(@Res() res: Response) {
    const stream = await this.adminService.exportUsersToCsv();
    res.set({
      'Content-Type': 'text/csv',
      'Content-Disposition': 'attachment; filename="users.csv"',
    });
    stream.pipe(res);
  }
}
