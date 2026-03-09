import { Controller, Get, Patch, Body, UseGuards, Request } from '@nestjs/common';
import { ApiTags, ApiBearerAuth } from '@nestjs/swagger';
import { UsersService } from './users.service';
import { JwtAuthGuard } from '@modules/auth/guards/jwt-auth.guard';

@ApiTags('Users')
@Controller('users')
@UseGuards(JwtAuthGuard)
@ApiBearerAuth()
export class UsersController {
  constructor(private readonly usersService: UsersService) {}

  @Get('me')
  getProfile(@Request() req) {
    return this.usersService.getUserById(req.user.id);
  }

  @Patch('me/role')
  switchRole(@Request() req, @Body() body: { role: 'renter' | 'owner' }) {
    return this.usersService.switchRole(req.user.id, body.role);
  }

  @Patch('me')
  updateProfile(@Request() req, @Body() body: { name?: string; profilePic?: string }) {
    return this.usersService.updateProfile(req.user.id, body);
  }
}
