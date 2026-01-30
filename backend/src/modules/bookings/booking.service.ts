import {
  Injectable,
  ConflictException,
  NotFoundException,
  UnauthorizedException,
  ForbiddenException,
} from '@nestjs/common';
import { EntityManager, EntityRepository, LockMode } from '@mikro-orm/postgresql';
import { InjectRepository } from '@mikro-orm/nestjs';
import { Booking } from './entities/booking.entity';
import { Vehicle } from '@modules/vehicles/entities/vehicle.entity';
import { User } from '@modules/users/entities/user.entity';
import { Payment } from '@modules/payments/entities/payment.entity';
import { CreateBookingDto } from './dto/create-booking.dto';
import { PayHereService } from '@modules/payments/payhere.service';

@Injectable()
export class BookingService {
  constructor(
    private readonly em: EntityManager,
    @InjectRepository(Booking)
    private readonly bookingRepository: EntityRepository<Booking>,
    @InjectRepository(Vehicle)
    private readonly vehicleRepository: EntityRepository<Vehicle>,
    @InjectRepository(User)
    private readonly userRepository: EntityRepository<User>,
    @InjectRepository(Payment)
    private readonly paymentRepository: EntityRepository<Payment>,
    private readonly payHereService: PayHereService,
  ) {}

  async createBooking(renterId: string, createBookingDto: CreateBookingDto) {
    const { vehicleId, startDate, endDate, pickupLocation, dropoffLocation, flightNumber } = createBookingDto;
    const start = new Date(startDate);
    const end = new Date(endDate);

    if (start >= end) {
      throw new ConflictException('End date must be after start date');
    }

    if (start < new Date()) {
      throw new ConflictException('Start date must be in the future');
    }

    return await this.em.transactional(async (em) => {
      // 1. Lock the vehicle row (PESSIMISTIC_WRITE)
      const vehicle = await em.findOne(Vehicle, { id: vehicleId }, { lockMode: LockMode.PESSIMISTIC_WRITE });
      if (!vehicle) {
        throw new NotFoundException('Vehicle not found');
      }

      const renter = await em.findOne(User, { id: renterId });
      if (!renter) {
        throw new NotFoundException('User not found');
      }

      // 2. Check Availability
      const overlappingBooking = await em.findOne(Booking, {
        vehicle: vehicleId,
        $or: [
          { startDate: { $lt: end }, endDate: { $gt: start } },
        ],
        status: { $in: ['pending', 'confirmed', 'paid', 'completed'] },
      });

      if (overlappingBooking) {
        throw new ConflictException('Vehicle is already booked for these dates');
      }

      // 3. Calculate Total Price
      const diffTime = Math.abs(end.getTime() - start.getTime());
      const diffDays = Math.ceil(diffTime / (1000 * 60 * 60 * 24)) || 1;
      const totalPrice = diffDays * vehicle.pricePerDay;

      // 4. Create Booking
      const booking = em.create(Booking, {
        renter: renter.id,
        vehicle: vehicle.id,
        startDate: start,
        endDate: end,
        pickupLocation,
        dropoffLocation,
        flightNumber,
        totalPrice,
        currency: 'LKR',
        status: 'pending',
      });

      // 5. Create Payment Record
      const payment = em.create(Payment, {
        booking: booking.id,
        amount: totalPrice,
        status: 'pending',
        method: 'PayHere',
      });

      booking.payment = payment;

      await em.persistAndFlush([booking, payment]);

      // 6. Generate PayHere Payment Link
      const paymentLink = this.payHereService.generatePaymentLink({
        orderId: booking.id,
        items: `Booking for ${vehicle.brand} ${vehicle.name}`,
        amount: totalPrice,
        currency: 'LKR',
        firstName: renter.name.split(' ')[0] || 'Guest',
        lastName: renter.name.split(' ').slice(1).join(' ') || 'User',
        email: renter.email,
        phone: renter.phone,
        address: 'N/A',
        city: 'Colombo',
        country: 'Sri Lanka',
      });

      return {
        booking,
        paymentLink,
      };
    });
  }

  async confirmBooking(bookingId: string, gatewayRef: string) {
    const booking = await this.bookingRepository.findOne({ id: bookingId }, { populate: ['payment'] as any });
    if (!booking) {
      throw new NotFoundException('Booking not found');
    }

    booking.status = 'confirmed';
    if (booking.payment) {
      booking.payment.status = 'success';
      booking.payment.gatewayRef = gatewayRef;
    }

    await this.em.flush();
    
    // TODO: Send notifications to owner and renter
    
    return booking;
  }

  async cancelBooking(bookingId: string, userId: string) {
    const booking = await this.bookingRepository.findOne(
      { id: bookingId },
      { populate: ['payment', 'vehicle', 'vehicle.owner'] as any },
    );

    if (!booking) {
      throw new NotFoundException('Booking not found');
    }

    const isRenter = booking.renter.id === userId;
    const isOwner = booking.vehicle.owner.id === userId;

    if (!isRenter && !isOwner) {
      throw new ForbiddenException('You are not authorized to cancel this booking');
    }

    booking.status = 'cancelled';
    
    if (booking.payment && booking.payment.status === 'success') {
      const refunded = await this.payHereService.refundPayment({
        paymentId: booking.payment.gatewayRef,
        amount: booking.totalPrice,
      });
      if (refunded) {
        booking.payment.status = 'failed'; // Or add a 'refunded' status to enum
      }
    }

    await this.em.flush();
    return booking;
  }

  async getBookingById(id: string, userId: string) {
    const booking = await this.bookingRepository.findOne(
      { id },
      { populate: ['renter', 'vehicle', 'vehicle.owner', 'payment'] as any },
    );

    if (!booking) {
      throw new NotFoundException('Booking not found');
    }

    if (booking.renter.id !== userId && booking.vehicle.owner.id !== userId) {
      throw new ForbiddenException('You are not authorized to view this booking');
    }

    return booking;
  }

  async getUserBookings(userId: string) {
    return this.bookingRepository.find(
      { renter: userId },
      { populate: ['vehicle', 'vehicle.owner', 'payment'] as any, orderBy: { createdAt: 'DESC' } },
    );
  }

  async getOwnerBookings(ownerId: string) {
    return this.bookingRepository.find(
      { vehicle: { owner: ownerId } },
      { populate: ['renter', 'vehicle', 'payment'] as any, orderBy: { createdAt: 'DESC' } },
    );
  }
}
