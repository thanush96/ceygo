import { Controller, Get, Post, Patch, Body, Param, Query, UseGuards, Res } from '@nestjs/common';
import { Response } from 'express';
import { AdminService } from './admin.service';
import { JwtAuthGuard } from '@modules/auth/guards/jwt-auth.guard';
import { RolesGuard } from '@modules/auth/guards/roles.guard';
import { Roles } from '@common/decorators/roles.decorator';

@Controller('admin')
@UseGuards(JwtAuthGuard, RolesGuard)
@Roles('admin')
export class AdminController {
  constructor(private readonly adminService: AdminService) {}

  @Get('dashboard')
  getDashboardStats() {
    return this.adminService.getDashboardStats();
  }

  @Get('verifications/pending')
  getPendingVerifications() {
    return this.adminService.getPendingVerifications();
  }

  @Patch('users/:id/verify')
  verifyUser(
    @Param('id') id: string,
    @Body('status') status: string,
    @Body('reason') reason?: string,
  ) {
    return this.adminService.verifyUser(id, status, reason);
  }

  @Patch('vehicles/:id/verify')
  verifyVehicle(
    @Param('id') id: string,
    @Body('status') status: string,
    @Body('reason') reason?: string,
  ) {
    return this.adminService.verifyVehicle(id, status, reason);
  }

  @Get('users')
  getAllUsers(@Query() filters: any) {
    return this.adminService.getAllUsers(filters, filters.page, filters.limit);
  }

  @Patch('users/:id/ban')
  banUser(@Param('id') id: string, @Body('reason') reason: string) {
    return this.adminService.banUser(id, reason);
  }

  @Patch('users/:id/unban')
  unbanUser(@Param('id') id: string) {
    return this.adminService.unbanUser(id);
  }

  @Get('vehicles')
  getAllVehicles(@Query() filters: any) {
    return this.adminService.getAllVehicles(filters, filters.page, filters.limit);
  }

  @Patch('vehicles/:id/blacklist')
  blacklistVehicle(@Param('id') id: string, @Body('reason') reason: string) {
    return this.adminService.blacklistVehicle(id, reason);
  }

  @Get('reports/revenue')
  getRevenueReport(@Query('start') start: string, @Query('end') end: string) {
    return this.adminService.getRevenueReport(start, end);
  }

  @Get('export/users')
  async exportUsers(@Res() res: Response) {
    const stream = await this.adminService.exportUsersToCsv();
    res.set({
      'Content-Type': 'text/csv',
      'Content-Disposition': 'attachment; filename="users.csv"',
    });
    stream.pipe(res);
  }
}
