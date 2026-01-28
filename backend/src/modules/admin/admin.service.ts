import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { User } from '../users/entities/user.entity';
import { Driver } from '../drivers/entities/driver.entity';
import { Vehicle } from '../vehicles/entities/vehicle.entity';
import { Booking } from '../bookings/entities/booking.entity';
import { Payment } from '../payments/entities/payment.entity';
import { VehicleStatus } from '../../../common/enums/vehicle-status.enum';
import { BookingStatus } from '../../../common/enums/booking-status.enum';
import { PaymentStatus } from '../../../common/enums/payment-status.enum';
import { UserRole } from '../../../common/enums/user-role.enum';

@Injectable()
export class AdminService {
  constructor(
    @InjectRepository(User)
    private userRepository: Repository<User>,
    @InjectRepository(Driver)
    private driverRepository: Repository<Driver>,
    @InjectRepository(Vehicle)
    private vehicleRepository: Repository<Vehicle>,
    @InjectRepository(Booking)
    private bookingRepository: Repository<Booking>,
    @InjectRepository(Payment)
    private paymentRepository: Repository<Payment>,
  ) {}

  async getDashboardStats() {
    const [
      totalUsers,
      totalDrivers,
      totalVehicles,
      pendingVehicles,
      totalBookings,
      activeBookings,
      totalRevenue,
      commissionEarned,
    ] = await Promise.all([
      this.userRepository.count({ where: { role: UserRole.USER } }),
      this.driverRepository.count({ where: { isVerified: true } }),
      this.vehicleRepository.count({ where: { status: VehicleStatus.APPROVED } }),
      this.vehicleRepository.count({ where: { status: VehicleStatus.PENDING } }),
      this.bookingRepository.count(),
      this.bookingRepository.count({ where: { status: BookingStatus.ACTIVE } }),
      this.paymentRepository
        .createQueryBuilder('payment')
        .select('SUM(payment.amount)', 'total')
        .where('payment.status = :status', { status: PaymentStatus.COMPLETED })
        .getRawOne(),
      this.bookingRepository
        .createQueryBuilder('booking')
        .select('SUM(booking.commission)', 'total')
        .where('booking.status IN (:...statuses)', {
          statuses: [BookingStatus.COMPLETED, BookingStatus.CONFIRMED, BookingStatus.ACTIVE],
        })
        .getRawOne(),
    ]);

    return {
      users: {
        total: totalUsers,
        drivers: totalDrivers,
      },
      vehicles: {
        total: totalVehicles,
        pending: pendingVehicles,
      },
      bookings: {
        total: totalBookings,
        active: activeBookings,
      },
      revenue: {
        total: parseFloat(totalRevenue?.total || '0'),
        commission: parseFloat(commissionEarned?.total || '0'),
      },
    };
  }

  async approveVehicle(vehicleId: string): Promise<Vehicle> {
    const vehicle = await this.vehicleRepository.findOne({ where: { id: vehicleId } });
    if (!vehicle) {
      throw new NotFoundException('Vehicle not found');
    }

    vehicle.status = VehicleStatus.APPROVED;
    return this.vehicleRepository.save(vehicle);
  }

  async rejectVehicle(vehicleId: string, reason?: string): Promise<Vehicle> {
    const vehicle = await this.vehicleRepository.findOne({ where: { id: vehicleId } });
    if (!vehicle) {
      throw new NotFoundException('Vehicle not found');
    }

    vehicle.status = VehicleStatus.REJECTED;
    return this.vehicleRepository.save(vehicle);
  }

  async verifyDriver(driverId: string): Promise<Driver> {
    const driver = await this.driverRepository.findOne({ where: { id: driverId } });
    if (!driver) {
      throw new NotFoundException('Driver not found');
    }

    driver.isVerified = true;
    return this.driverRepository.save(driver);
  }

  async getAllUsers(page = 1, limit = 20) {
    const [users, total] = await this.userRepository.findAndCount({
      skip: (page - 1) * limit,
      take: limit,
      order: { createdAt: 'DESC' },
    });

    return {
      data: users,
      meta: {
        total,
        page,
        limit,
        totalPages: Math.ceil(total / limit),
      },
    };
  }

  async getAllVehicles(page = 1, limit = 20) {
    const [vehicles, total] = await this.vehicleRepository.findAndCount({
      skip: (page - 1) * limit,
      take: limit,
      relations: ['driver', 'images'],
      order: { createdAt: 'DESC' },
    });

    return {
      data: vehicles,
      meta: {
        total,
        page,
        limit,
        totalPages: Math.ceil(total / limit),
      },
    };
  }
}
