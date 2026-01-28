import { Injectable, NotFoundException, BadRequestException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Driver } from './entities/driver.entity';
import { User } from '../users/entities/user.entity';
import { CreateDriverDto } from './dto/create-driver.dto';

@Injectable()
export class DriversService {
  constructor(
    @InjectRepository(Driver)
    private driverRepository: Repository<Driver>,
    @InjectRepository(User)
    private userRepository: Repository<User>,
  ) {}

  async create(userId: string, dto: CreateDriverDto): Promise<Driver> {
    const user = await this.userRepository.findOne({ where: { id: userId } });
    if (!user) {
      throw new NotFoundException('User not found');
    }

    const existingDriver = await this.driverRepository.findOne({
      where: { userId },
    });
    if (existingDriver) {
      throw new BadRequestException('Driver profile already exists');
    }

    const driver = this.driverRepository.create({
      ...dto,
      userId,
      user,
    });

    // Update user role to driver
    await this.userRepository.update(userId, { role: 'driver' as any });

    return this.driverRepository.save(driver);
  }

  async findByUserId(userId: string): Promise<Driver> {
    const driver = await this.driverRepository.findOne({
      where: { userId },
      relations: ['user', 'vehicles'],
    });
    if (!driver) {
      throw new NotFoundException('Driver not found');
    }
    return driver;
  }

  async update(userId: string, updateData: Partial<Driver>): Promise<Driver> {
    const driver = await this.findByUserId(userId);
    Object.assign(driver, updateData);
    return this.driverRepository.save(driver);
  }
}
