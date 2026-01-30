import { Controller, Post, Body, Get, Param, Patch, UseGuards, Request } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiResponse, ApiBearerAuth } from '@nestjs/swagger';
import { Throttle } from '@nestjs/throttler';
import { BookingService } from './booking.service';
import { CreateBookingDto } from './dto/create-booking.dto';
import { JwtAuthGuard } from '@modules/auth/guards/jwt-auth.guard';
import { RolesGuard } from '@modules/auth/guards/roles.guard';
import { Roles } from '@common/decorators/roles.decorator';

@ApiTags('Bookings')
@Controller('bookings')
@Throttle({ booking: { limit: 10, ttl: 60000 } })
export class BookingController {
  constructor(private readonly bookingService: BookingService) {}

  @Post()
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Create a new booking' })
  @ApiResponse({ status: 201, description: 'Booking created successfully' })
  create(@Request() req, @Body() createBookingDto: CreateBookingDto) {
    return this.bookingService.createBooking(req.user.id, createBookingDto);
  }

  @Get()
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Get my bookings' })
  getUserBookings(@Request() req) {
    return this.bookingService.getUserBookings(req.user.id);
  }

  @Get('owner')
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles('owner', 'admin')
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Get bookings for my vehicles (Owner)' })
  getOwnerBookings(@Request() req) {
    return this.bookingService.getOwnerBookings(req.user.id);
  }

  @Get(':id')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Get booking details' })
  findOne(@Param('id') id: string, @Request() req) {
    return this.bookingService.getBookingById(id, req.user.id);
  }

  @Patch(':id/cancel')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Cancel a booking' })
  cancel(@Param('id') id: string, @Request() req) {
    return this.bookingService.cancelBooking(id, req.user.id);
  }

  @Post(':id/confirm')
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles('admin') // Usually confirmed by webhook, but adding an endpoint for admin/test
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Manually confirm booking (Admin/Test)' })
  confirm(@Param('id') id: string, @Body('gatewayRef') gatewayRef: string) {
    return this.bookingService.confirmBooking(id, gatewayRef);
  }
}
