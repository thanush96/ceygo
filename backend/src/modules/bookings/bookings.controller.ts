import {
  Controller,
  Get,
  Post,
  Put,
  Param,
  Body,
  UseGuards,
  Query,
} from '@nestjs/common';
import { ApiTags, ApiOperation, ApiBearerAuth } from '@nestjs/swagger';
import { BookingsService } from './bookings.service';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { CurrentUser } from '../auth/decorators/current-user.decorator';
import { User } from '../users/entities/user.entity';
import { CreateBookingDto } from './dto/create-booking.dto';

@ApiTags('bookings')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard)
@Controller('bookings')
export class BookingsController {
  constructor(private readonly bookingsService: BookingsService) {}

  @Post()
  @ApiOperation({ summary: 'Create a new booking' })
  async create(
    @CurrentUser() user: User,
    @Body() dto: CreateBookingDto,
  ) {
    return this.bookingsService.create(user.id, dto);
  }

  @Get()
  @ApiOperation({ summary: 'Get all bookings (user or driver)' })
  async findAll(
    @CurrentUser() user: User,
    @Query('type') type?: string,
  ) {
    if (type === 'driver' && user.role === 'driver' as any) {
      return this.bookingsService.findAll(undefined, user.id);
    }
    return this.bookingsService.findAll(user.id);
  }

  @Get(':id')
  @ApiOperation({ summary: 'Get booking details' })
  async findOne(
    @Param('id') id: string,
    @CurrentUser() user: User,
  ) {
    return this.bookingsService.findOne(id, user.id);
  }

  @Put(':id/cancel')
  @ApiOperation({ summary: 'Cancel a booking' })
  async cancel(
    @Param('id') id: string,
    @CurrentUser() user: User,
    @Body('reason') reason?: string,
  ) {
    return this.bookingsService.cancel(id, user.id, reason);
  }

  @Put(':id/complete')
  @ApiOperation({ summary: 'Complete a booking (Driver only)' })
  async complete(
    @Param('id') id: string,
    @CurrentUser() user: User,
  ) {
    return this.bookingsService.complete(id, user.id);
  }
}
