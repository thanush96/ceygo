import { Injectable, NotFoundException, ForbiddenException, Inject } from '@nestjs/common';
import { InjectRepository } from '@mikro-orm/nestjs';
import { EntityRepository, EntityManager, FilterQuery } from '@mikro-orm/postgresql';
import { CACHE_MANAGER } from '@nestjs/cache-manager';
import { Cache } from 'cache-manager';
import { Vehicle } from './entities/vehicle.entity';
import { CreateVehicleDto } from './dto/create-vehicle.dto';
import { UpdateVehicleDto } from './dto/update-vehicle.dto';
import { SearchVehicleDto } from './dto/search-vehicle.dto';
import { Booking } from '@modules/bookings/entities/booking.entity';

@Injectable()
export class VehiclesService {
  constructor(
    @InjectRepository(Vehicle)
    private readonly vehicleRepository: EntityRepository<Vehicle>,
    @InjectRepository(Booking)
    private readonly bookingRepository: EntityRepository<Booking>,
    private readonly em: EntityManager,
    @Inject(CACHE_MANAGER) private cacheManager: Cache,
  ) {}

  async createVehicle(ownerId: string, createVehicleDto: CreateVehicleDto): Promise<Vehicle> {
    const vehicle = this.vehicleRepository.create({
      ...createVehicleDto,
      owner: ownerId,
    });
    await this.em.persistAndFlush(vehicle);
    return vehicle;
  }

  async updateVehicle(vehicleId: string, ownerId: string, updateVehicleDto: UpdateVehicleDto): Promise<Vehicle> {
    const vehicle = await this.vehicleRepository.findOne({ id: vehicleId, deletedAt: null });
    if (!vehicle) {
      throw new NotFoundException('Vehicle not found');
    }

    if (vehicle.owner.id !== ownerId) {
      throw new ForbiddenException('You are not the owner of this vehicle');
    }

    Object.assign(vehicle, updateVehicleDto);
    await this.em.flush();
    
    // Invalidate cache
    await this.cacheManager.del(`vehicle:${vehicleId}`);
    
    return vehicle;
  }

  async deleteVehicle(vehicleId: string, ownerId: string): Promise<void> {
    const vehicle = await this.vehicleRepository.findOne({ id: vehicleId, deletedAt: null });
    if (!vehicle) {
      throw new NotFoundException('Vehicle not found');
    }

    if (vehicle.owner.id !== ownerId) {
      throw new ForbiddenException('You are not the owner of this vehicle');
    }

    vehicle.deletedAt = new Date();
    await this.em.flush();
    
    // Invalidate cache
    await this.cacheManager.del(`vehicle:${vehicleId}`);
  }

  async getVehicleById(id: string): Promise<Vehicle> {
    const cached = await this.cacheManager.get<Vehicle>(`vehicle:${id}`);
    if (cached) return cached;

    const vehicle = await this.vehicleRepository.findOne(
      { id, deletedAt: null },
      { populate: ['owner'] as any },
    );

    if (!vehicle) {
      throw new NotFoundException('Vehicle not found');
    }

    await this.cacheManager.set(`vehicle:${id}`, vehicle, 1800000); // 30 min
    return vehicle;
  }

  async getOwnerVehicles(ownerId: string): Promise<Vehicle[]> {
    return this.vehicleRepository.find({ owner: ownerId, deletedAt: null });
  }

  async searchVehicles(filters: SearchVehicleDto) {
    const {
      location,
      fuelType,
      transmission,
      minPrice,
      maxPrice,
      seats,
      startDate,
      endDate,
      page = 1,
      limit = 20,
      sortBy = 'createdAt',
      sortOrder = 'DESC',
    } = filters;

    const cacheKey = `search:${JSON.stringify(filters)}`;
    const cachedResults = await this.cacheManager.get(cacheKey);
    if (cachedResults) return cachedResults;

    const query: FilterQuery<Vehicle> = { deletedAt: null, status: 'available' };

    if (location) query.location = { $ilike: `%${location}%` };
    if (fuelType) query.fuelType = fuelType;
    if (transmission) query.transmission = transmission;
    if (seats) query.seats = { $gte: seats };
    if (minPrice || maxPrice) {
      query.pricePerDay = {};
      if (minPrice) query.pricePerDay.$gte = minPrice;
      if (maxPrice) query.pricePerDay.$lte = maxPrice;
    }

    // Availability Filter
    if (startDate && endDate) {
      const start = new Date(startDate);
      const end = new Date(endDate);

      const bookedVehicleIds = await this.bookingRepository.find(
        {
          $or: [
            { startDate: { $lt: end }, endDate: { $gt: start } },
          ],
          status: { $in: ['pending', 'confirmed', 'paid', 'completed'] },
        },
        { fields: ['vehicle'] as any },
      );

      const excludedIds = bookedVehicleIds.map((b) => b.vehicle.id);
      if (excludedIds.length > 0) {
        query.id = { $nin: excludedIds };
      }
    }

    const [items, total] = await this.vehicleRepository.findAndCount(query, {
      limit,
      offset: (page - 1) * limit,
      orderBy: { [sortBy]: sortOrder } as any,
    });

    const result = {
      items,
      meta: {
        totalItems: total,
        itemCount: items.length,
        itemsPerPage: limit,
        totalPages: Math.ceil(total / limit),
        currentPage: page,
      },
    };

    await this.cacheManager.set(cacheKey, result, 3600000); // 1 hour
    return result;
  }

  async checkAvailability(vehicleId: string, startDate: string, endDate: string): Promise<boolean> {
    const cacheKey = `avail:${vehicleId}:${startDate}:${endDate}`;
    const cached = await this.cacheManager.get<boolean>(cacheKey);
    if (cached !== undefined) return cached;

    const start = new Date(startDate);
    const end = new Date(endDate);

    const overlapping = await this.bookingRepository.findOne({
      vehicle: vehicleId,
      $or: [
        { startDate: { $lt: end }, endDate: { $gt: start } },
      ],
      status: { $in: ['pending', 'confirmed', 'paid', 'completed'] },
    });

    const isAvailable = !overlapping;
    await this.cacheManager.set(cacheKey, isAvailable, 300000); // 5 min
    return isAvailable;
  }
}
