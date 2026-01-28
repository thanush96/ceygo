import {
  Injectable,
  NotFoundException,
  BadRequestException,
  ForbiddenException,
} from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository, Between } from 'typeorm';
import { Booking } from './entities/booking.entity';
import { Vehicle } from '../vehicles/entities/vehicle.entity';
import { User } from '../users/entities/user.entity';
import { Payment } from '../payments/entities/payment.entity';
import { CreateBookingDto } from './dto/create-booking.dto';
import { BookingStatus } from '../../../common/enums/booking-status.enum';
import { differenceInDays } from 'date-fns';
import { ConfigService } from '@nestjs/config';
import { PaymentsService } from '../payments/payments.service';

@Injectable()
export class BookingsService {
  constructor(
    @InjectRepository(Booking)
    private bookingRepository: Repository<Booking>,
    @InjectRepository(Vehicle)
    private vehicleRepository: Repository<Vehicle>,
    @InjectRepository(Payment)
    private paymentRepository: Repository<Payment>,
    private configService: ConfigService,
    private paymentsService: PaymentsService,
  ) {}

  async create(userId: string, dto: CreateBookingDto): Promise<Booking> {
    const vehicle = await this.vehicleRepository.findOne({
      where: { id: dto.vehicleId },
      relations: ['driver'],
    });
    if (!vehicle) {
      throw new NotFoundException('Vehicle not found');
    }

    if (vehicle.status !== 'approved' as any || !vehicle.isAvailable) {
      throw new BadRequestException('Vehicle is not available for booking');
    }

    const startDate = new Date(dto.startDate);
    const endDate = new Date(dto.endDate);

    if (startDate >= endDate) {
      throw new BadRequestException('End date must be after start date');
    }

    if (startDate < new Date()) {
      throw new BadRequestException('Start date cannot be in the past');
    }

    // Check availability - find ALL conflicting bookings
    const conflictingBookings = await this.bookingRepository
      .createQueryBuilder('booking')
      .where('booking.vehicleId = :vehicleId', { vehicleId: dto.vehicleId })
      .andWhere('booking.status IN (:...statuses)', {
        statuses: [BookingStatus.CONFIRMED, BookingStatus.ACTIVE],
      })
      .andWhere(
        '(booking.startDate <= :endDate AND booking.endDate >= :startDate)',
        { startDate, endDate },
      )
      .getMany();

    if (conflictingBookings.length > 0) {
      throw new BadRequestException('Vehicle is not available for the selected dates');
    }

    // Calculate pricing
    const days = differenceInDays(endDate, startDate) || 1;
    const totalPrice = vehicle.pricePerDay * days;

    // Calculate commission
    const commissionPercentage = parseFloat(
      this.configService.get<string>('COMMISSION_PERCENTAGE', '15'),
    );
    const commission = (totalPrice * commissionPercentage) / 100;
    const driverEarnings = totalPrice - commission;

    const booking = this.bookingRepository.create({
      ...dto,
      userId,
      vehicleId: dto.vehicleId,
      startDate,
      endDate,
      totalPrice,
      commission,
      driverEarnings,
      status: BookingStatus.PENDING,
    });

    return this.bookingRepository.save(booking);
  }

  async findAll(userId?: string, driverId?: string) {
    const query = this.bookingRepository
      .createQueryBuilder('booking')
      .leftJoinAndSelect('booking.vehicle', 'vehicle')
      .leftJoinAndSelect('vehicle.images', 'images')
      .leftJoinAndSelect('vehicle.driver', 'driver')
      .leftJoinAndSelect('driver.user', 'driverUser')
      .leftJoinAndSelect('booking.user', 'user')
      .leftJoinAndSelect('booking.payment', 'payment');

    if (userId) {
      query.where('booking.userId = :userId', { userId });
    }

    if (driverId) {
      query
        .leftJoin('vehicle.driver', 'vd')
        .where('vd.userId = :driverId', { driverId });
    }

    return query.orderBy('booking.createdAt', 'DESC').getMany();
  }

  async findOne(id: string, userId?: string): Promise<Booking> {
    const booking = await this.bookingRepository.findOne({
      where: { id },
      relations: ['vehicle', 'vehicle.images', 'vehicle.driver', 'vehicle.driver.user', 'user', 'payment'],
    });

    if (!booking) {
      throw new NotFoundException('Booking not found');
    }

    if (userId && booking.userId !== userId) {
      throw new ForbiddenException('You can only view your own bookings');
    }

    return booking;
  }

  async confirm(id: string, paymentId: string): Promise<Booking> {
    const booking = await this.findOne(id);
    if (booking.status !== BookingStatus.PENDING) {
      throw new BadRequestException('Booking cannot be confirmed');
    }

    booking.status = BookingStatus.CONFIRMED;
    return this.bookingRepository.save(booking);
  }

  async cancel(id: string, userId: string, reason?: string): Promise<Booking> {
    const booking = await this.findOne(id, userId);

    if (booking.status === BookingStatus.CANCELLED) {
      throw new BadRequestException('Booking is already cancelled');
    }

    if (booking.status === BookingStatus.COMPLETED) {
      throw new BadRequestException('Cannot cancel a completed booking');
    }

    // If payment exists and booking was confirmed/active, process refund
    if (booking.payment && 
        (booking.status === BookingStatus.CONFIRMED || booking.status === BookingStatus.ACTIVE)) {
      try {
        await this.paymentsService.refund(booking.payment.id);
      } catch (error) {
        // Log error but continue with cancellation
        console.error('Refund failed during cancellation:', error);
      }
    }

    booking.status = BookingStatus.CANCELLED;
    booking.cancellationReason = reason;
    booking.cancelledAt = new Date();

    return this.bookingRepository.save(booking);
  }

  async complete(id: string, driverId: string): Promise<Booking> {
    const booking = await this.findOne(id);
    const vehicle = await this.vehicleRepository.findOne({
      where: { id: booking.vehicleId },
      relations: ['driver'],
    });

    if (vehicle.driver.userId !== driverId) {
      throw new ForbiddenException('Only the vehicle owner can complete bookings');
    }

    if (booking.status !== BookingStatus.ACTIVE) {
      throw new BadRequestException('Only active bookings can be completed');
    }

    booking.status = BookingStatus.COMPLETED;

    // Update vehicle stats
    vehicle.tripCount += 1;
    await this.vehicleRepository.save(vehicle);

    return this.bookingRepository.save(booking);
  }
}
