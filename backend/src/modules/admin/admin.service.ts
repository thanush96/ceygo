import { Injectable, NotFoundException, BadRequestException } from '@nestjs/common';
import { InjectRepository } from '@mikro-orm/nestjs';
import { EntityRepository, EntityManager, FilterQuery } from '@mikro-orm/postgresql';
import { User } from '@modules/users/entities/user.entity';
import { Vehicle } from '@modules/vehicles/entities/vehicle.entity';
import { Booking } from '@modules/bookings/entities/booking.entity';
import { Payment } from '@modules/payments/entities/payment.entity';
import { Parser } from 'json2csv';
import { Readable } from 'stream';
import { AuditService } from '@common/services/audit.service';

@Injectable()
export class AdminService {
  constructor(
    @InjectRepository(User)
    private readonly userRepository: EntityRepository<User>,
    @InjectRepository(Vehicle)
    private readonly vehicleRepository: EntityRepository<Vehicle>,
    @InjectRepository(Booking)
    private readonly bookingRepository: EntityRepository<Booking>,
    @InjectRepository(Payment)
    private readonly paymentRepository: EntityRepository<Payment>,
    private readonly em: EntityManager,
    private readonly auditService: AuditService,
  ) {}

  // --- Verification ---

  async getPendingVerifications() {
    const users = await this.userRepository.find({ verificationStatus: 'pending' });
    const vehicles = await this.vehicleRepository.find({ verificationStatus: 'pending' });
    return { users, vehicles };
  }

  async verifyUser(userId: string, status: string, reason?: string) {
    const user = await this.userRepository.findOne({ id: userId });
    if (!user) throw new NotFoundException('User not found');
    
    user.verificationStatus = status;
    if (reason) user.reason = reason;
    await this.em.flush();
    this.auditService.logAction('ADMIN', 'USER_VERIFY', { userId, status, reason });
    return user;
  }

  async verifyVehicle(vehicleId: string, status: string, reason?: string) {
    const vehicle = await this.vehicleRepository.findOne({ id: vehicleId });
    if (!vehicle) throw new NotFoundException('Vehicle not found');
    
    vehicle.verificationStatus = status;
    if (reason) vehicle.reason = reason;
    await this.em.flush();
    this.auditService.logAction('ADMIN', 'VEHICLE_VERIFY', { vehicleId, status, reason });
    return vehicle;
  }

  // --- User Management ---

  async getAllUsers(filters: any, page = 1, limit = 20) {
    const query: FilterQuery<User> = {};
    if (filters.role) query.role = filters.role;
    if (filters.verificationStatus) query.verificationStatus = filters.verificationStatus;
    if (filters.status) query.status = filters.status;

    const [items, total] = await this.userRepository.findAndCount(query, {
      limit,
      offset: (page - 1) * limit,
      orderBy: { createdAt: 'DESC' } as any,
    });

    return { items, total, page, limit };
  }

  async banUser(userId: string, reason: string) {
    const user = await this.userRepository.findOne({ id: userId });
    if (!user) throw new NotFoundException('User not found');
    
    user.status = 'banned';
    user.reason = reason;
    await this.em.flush();
    return user;
  }

  async unbanUser(userId: string) {
    const user = await this.userRepository.findOne({ id: userId });
    if (!user) throw new NotFoundException('User not found');
    
    user.status = 'active';
    user.reason = null;
    await this.em.flush();
    return user;
  }

  // --- Vehicle Management ---

  async getAllVehicles(filters: any, page = 1, limit = 20) {
    const query: FilterQuery<Vehicle> = { deletedAt: null };
    if (filters.verificationStatus) query.verificationStatus = filters.verificationStatus;
    if (filters.isBlacklisted !== undefined) query.isBlacklisted = filters.isBlacklisted;

    const [items, total] = await this.vehicleRepository.findAndCount(query, {
      limit,
      offset: (page - 1) * limit,
      orderBy: { createdAt: 'DESC' } as any,
    });

    return { items, total, page, limit };
  }

  async blacklistVehicle(vehicleId: string, reason: string) {
    const vehicle = await this.vehicleRepository.findOne({ id: vehicleId });
    if (!vehicle) throw new NotFoundException('Vehicle not found');
    
    vehicle.isBlacklisted = true;
    vehicle.reason = reason;
    await this.em.flush();
    return vehicle;
  }

  // --- Analytics ---

  async getDashboardStats() {
    const [users, vehicles, bookings] = await Promise.all([
      this.userRepository.count(),
      this.vehicleRepository.count({ deletedAt: null }),
      this.bookingRepository.count(),
    ]);

    const revenue = await this.paymentRepository
      .qb()
      .where({ status: 'success' })
      .select('sum(amount) as total')
      .execute('get') as any;

    return {
      totalUsers: users,
      totalVehicles: vehicles,
      totalBookings: bookings,
      totalRevenue: Number(revenue?.total) || 0,
    };
  }

  async getRevenueReport(startDate: string, endDate: string) {
    // Simplified grouping - in production would use a proper SQL query with date_trunc
    const payments = await this.paymentRepository.find({
      status: 'success',
      booking: {
        startDate: { $gte: new Date(startDate) },
        endDate: { $lte: new Date(endDate) },
      },
    }, { populate: ['booking'] as any });

    return payments.reduce((acc: any, p) => {
      const date = p.booking.startDate.toISOString().split('T')[0];
      acc[date] = (acc[date] || 0) + Number(p.amount);
      return acc;
    }, {});
  }

  // --- Exports ---

  async exportUsersToCsv(): Promise<Readable> {
    const users = await this.userRepository.findAll();
    const fields = ['id', 'name', 'email', 'phone', 'role', 'verificationStatus', 'status', 'createdAt'];
    const parser = new Parser({ fields });
    const csv = parser.parse(users);
    
    const stream = new Readable();
    stream.push(csv);
    stream.push(null);
    return stream;
  }
}
