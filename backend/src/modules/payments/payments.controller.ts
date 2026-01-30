import { Controller, Post, Get, Body, Param, UseGuards, HttpException, HttpStatus, Logger } from '@nestjs/common';
import { PayHereService } from './payhere.service';
import { BookingService } from '@modules/bookings/booking.service';
import { JwtAuthGuard } from '@modules/auth/guards/jwt-auth.guard';

@Controller('payments')
export class PaymentsController {
  private readonly logger = new Logger(PaymentsController.name);

  constructor(
    private readonly payHereService: PayHereService,
    private readonly bookingService: BookingService,
  ) {}

  @Post('notify')
  async handlePayHereNotify(@Body() notifyDto: any) {
    this.logger.log(`Received PayHere notification for order: ${notifyDto.order_id}`);

    // Signature verification (Security)
    if (!this.payHereService.verifySignature(notifyDto)) {
      this.logger.warn(`Invalid signature for order: ${notifyDto.order_id}`);
      throw new HttpException('Invalid signature', HttpStatus.BAD_REQUEST);
    }

    const { order_id, payment_id, status_code } = notifyDto;

    // PayHere status codes: 2 = Success, 0 = Pending, -1 = Canceled, -2 = Failed, -3 = Charged Back
    if (status_code === '2') {
      this.logger.log(`Payment successful for order: ${order_id}`);
      await this.bookingService.confirmBooking(order_id, payment_id);
    } else {
      this.logger.log(`Payment status for order ${order_id}: ${status_code}`);
    }

    // PayHere expects a 200 OK response
    return 'OK';
  }

  @Get(':bookingId/status')
  @UseGuards(JwtAuthGuard)
  async getPaymentStatus(@Param('bookingId') bookingId: string) {
    return this.payHereService.getPaymentStatus(bookingId);
  }
}
