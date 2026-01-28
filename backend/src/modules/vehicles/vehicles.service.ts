import { Injectable, NotFoundException, BadRequestException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository, Between, LessThanOrEqual, MoreThanOrEqual } from 'typeorm';
import { Vehicle } from './entities/vehicle.entity';
import { VehicleImage } from './entities/vehicle-image.entity';
import { Driver } from '../drivers/entities/driver.entity';
import { Booking } from '../bookings/entities/booking.entity';
import { CreateVehicleDto } from './dto/create-vehicle.dto';
import { UpdateVehicleDto } from './dto/update-vehicle.dto';
import { SearchVehiclesDto } from './dto/search-vehicles.dto';
import { VehicleStatus } from '../../../common/enums/vehicle-status.enum';

@Injectable()
export class VehiclesService {
  constructor(
    @InjectRepository(Vehicle)
    private vehicleRepository: Repository<Vehicle>,
    @InjectRepository(VehicleImage)
    private vehicleImageRepository: Repository<VehicleImage>,
    @InjectRepository(Driver)
    private driverRepository: Repository<Driver>,
    @InjectRepository(Booking)
    private bookingRepository: Repository<Booking>,
  ) {}

  async create(driverId: string, dto: CreateVehicleDto): Promise<Vehicle> {
    const driver = await this.driverRepository.findOne({ where: { userId: driverId } });
    if (!driver) {
      throw new NotFoundException('Driver not found');
    }

    const existingVehicle = await this.vehicleRepository.findOne({
      where: { licensePlate: dto.licensePlate },
    });
    if (existingVehicle) {
      throw new BadRequestException('Vehicle with this license plate already exists');
    }

    const vehicle = this.vehicleRepository.create({
      ...dto,
      driverId: driver.id,
      driver,
      status: VehicleStatus.PENDING,
    });

    return this.vehicleRepository.save(vehicle);
  }

  async findAll(dto: SearchVehiclesDto) {
    const {
      make,
      model,
      location,
      transmission,
      fuelType,
      minPrice,
      maxPrice,
      seats,
      startDate,
      endDate,
      page = 1,
      limit = 20,
    } = dto;

    const query = this.vehicleRepository
      .createQueryBuilder('vehicle')
      .leftJoinAndSelect('vehicle.images', 'images')
      .leftJoinAndSelect('vehicle.driver', 'driver')
      .where('vehicle.status = :status', { status: VehicleStatus.APPROVED })
      .andWhere('vehicle.isAvailable = :isAvailable', { isAvailable: true });

    if (make) {
      query.andWhere('vehicle.make ILIKE :make', { make: `%${make}%` });
    }
    if (model) {
      query.andWhere('vehicle.model ILIKE :model', { model: `%${model}%` });
    }
    if (location) {
      query.andWhere('vehicle.location ILIKE :location', { location: `%${location}%` });
    }
    if (transmission) {
      query.andWhere('vehicle.transmission = :transmission', { transmission });
    }
    if (fuelType) {
      query.andWhere('vehicle.fuelType = :fuelType', { fuelType });
    }
    if (minPrice !== undefined) {
      query.andWhere('vehicle.pricePerDay >= :minPrice', { minPrice });
    }
    if (maxPrice !== undefined) {
      query.andWhere('vehicle.pricePerDay <= :maxPrice', { maxPrice });
    }
    if (seats) {
      query.andWhere('vehicle.seats >= :seats', { seats });
    }

    // Check availability for date range
    if (startDate && endDate) {
      const start = new Date(startDate);
      const end = new Date(endDate);

      const unavailableVehicleIds = await this.bookingRepository
        .createQueryBuilder('booking')
        .select('booking.vehicleId')
        .where('booking.status IN (:...statuses)', {
          statuses: ['confirmed', 'active'],
        })
        .andWhere(
          '(booking.startDate <= :end AND booking.endDate >= :start)',
          { start, end },
        )
        .getMany();

      const unavailableIds = unavailableVehicleIds.map((b) => b.vehicleId);
      if (unavailableIds.length > 0) {
        query.andWhere('vehicle.id NOT IN (:...unavailableIds)', {
          unavailableIds,
        });
      }
    }

    const skip = (page - 1) * limit;
    const [vehicles, total] = await query
      .skip(skip)
      .take(limit)
      .orderBy('vehicle.createdAt', 'DESC')
      .getManyAndCount();

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

  async findOne(id: string): Promise<Vehicle> {
    const vehicle = await this.vehicleRepository.findOne({
      where: { id },
      relations: ['images', 'driver', 'driver.user'],
    });
    if (!vehicle) {
      throw new NotFoundException('Vehicle not found');
    }
    return vehicle;
  }

  async findByDriver(driverId: string) {
    const driver = await this.driverRepository.findOne({ where: { userId: driverId } });
    if (!driver) {
      throw new NotFoundException('Driver not found');
    }

    return this.vehicleRepository.find({
      where: { driverId: driver.id },
      relations: ['images'],
      order: { createdAt: 'DESC' },
    });
  }

  async update(id: string, driverId: string, dto: UpdateVehicleDto): Promise<Vehicle> {
    const vehicle = await this.findOne(id);
    const driver = await this.driverRepository.findOne({ where: { userId: driverId } });

    if (vehicle.driverId !== driver.id) {
      throw new BadRequestException('You can only update your own vehicles');
    }

    Object.assign(vehicle, dto);
    return this.vehicleRepository.save(vehicle);
  }

  async checkAvailability(vehicleId: string, startDate: Date, endDate: Date): Promise<boolean> {
    const conflictingBookings = await this.bookingRepository.count({
      where: {
        vehicleId,
        status: 'confirmed' as any,
        startDate: LessThanOrEqual(endDate),
        endDate: MoreThanOrEqual(startDate),
      },
    });

    return conflictingBookings === 0;
  }

  async addImage(vehicleId: string, url: string, key: string, isPrimary = false) {
    if (isPrimary) {
      // Unset other primary images
      await this.vehicleImageRepository.update(
        { vehicleId },
        { isPrimary: false },
      );
    }

    const image = this.vehicleImageRepository.create({
      vehicleId,
      url,
      key,
      isPrimary,
    });

    return this.vehicleImageRepository.save(image);
  }

  async deleteImage(imageId: string, driverId: string) {
    const image = await this.vehicleImageRepository.findOne({
      where: { id: imageId },
      relations: ['vehicle', 'vehicle.driver'],
    });

    if (!image) {
      throw new NotFoundException('Image not found');
    }

    if (image.vehicle.driver.userId !== driverId) {
      throw new BadRequestException('You can only delete your own vehicle images');
    }

    await this.vehicleImageRepository.remove(image);
  }
}
