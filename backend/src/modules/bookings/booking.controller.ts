import { Controller, Post, Body, UseGuards, Request } from '@nestjs/common';
import { BookingService } from './booking.service';
import { CreateBookingDto } from './dto/create-booking.dto';

@Controller('bookings')
export class BookingController {
  constructor(private readonly bookingService: BookingService) {}

  @Post()
  // Note: Assuming a JWT guard exists to populate req.user, but for now I'll use a mocked userId if not available
  // or just take it from the body for testing if no auth is enforced yet.
  // The user requested the service, I'll implement the controller to call it.
  async create(@Body() createBookingDto: CreateBookingDto, @Request() req) {
    // In a real app, userId would come from req.user.id
    // For now, I'll use a placeholder or check if req.user exists
    const userId = req.user?.id || 'placeholder-id'; 
    return this.bookingService.createBooking(userId, createBookingDto);
  }
}
