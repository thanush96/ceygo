import { Injectable, ConflictException, NotFoundException } from '@nestjs/common';
import { EntityManager, EntityRepository } from '@mikro-orm/postgresql';
import { InjectRepository } from '@mikro-orm/nestjs';
import { Booking } from './entities/booking.entity';
import { Vehicle } from '@modules/vehicles/entities/vehicle.entity';
import { User } from '@modules/users/entities/user.entity';
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
    private readonly payHereService: PayHereService,
  ) {}

  async createBooking(userId: string, createBookingDto: CreateBookingDto) {
    const { vehicleId, startDate, endDate } = createBookingDto;
    const start = new Date(startDate);
    const end = new Date(endDate);

    return await this.em.transactional(async (em) => {
      // 1. Get Vehicle and User
      const vehicle = await em.findOne(Vehicle, { id: vehicleId });
      if (!vehicle) {
        throw new NotFoundException('Vehicle not found');
      }

      const user = await em.findOne(User, { id: userId });
      if (!user) {
        throw new NotFoundException('User not found');
      }

      // 2. Check Availability
      const overlappingBooking = await em.findOne(Booking, {
        vehicle: vehicleId,
        $or: [
          {
            startDate: { $lt: end },
            endDate: { $gt: start },
          },
        ],
        status: { $in: ['pending', 'confirmed', 'completed'] },
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
        renter: user.id,
        vehicle: vehicle.id,
        startDate: start,
        endDate: end,
        pickupLocation: createBookingDto.pickupLocation,
        dropoffLocation: createBookingDto.dropoffLocation,
        totalPrice,
        status: 'pending',
      });

      await em.persistAndFlush(booking);

      // 5. Generate PayHere Payment Link
      const paymentLink = this.payHereService.generatePaymentLink({
        orderId: booking.id,
        items: `Booking for ${vehicle.brand} ${vehicle.name}`,
        amount: totalPrice,
        currency: 'LKR',
        firstName: user.name.split(' ')[0] || 'Guest',
        lastName: user.name.split(' ').slice(1).join(' ') || 'User',
        email: user.email,
        phone: user.phone,
        address: 'N/A', // Placeholders as User entity lacks these
        city: 'Colombo',
        country: 'Sri Lanka',
      });

      return {
        booking,
        paymentLink,
      };
    });
  }
}
