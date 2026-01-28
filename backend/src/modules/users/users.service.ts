import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { User } from './entities/user.entity';
import { Wallet } from './entities/wallet.entity';
import { RegisterDto } from '../auth/dto/register.dto';
import { UpdateUserDto } from './dto/update-user.dto';

@Injectable()
export class UsersService {
  constructor(
    @InjectRepository(User)
    private userRepository: Repository<User>,
    @InjectRepository(Wallet)
    private walletRepository: Repository<Wallet>,
  ) {}

  async create(dto: RegisterDto): Promise<User> {
    const user = this.userRepository.create(dto);
    const savedUser = await this.userRepository.save(user);

    // Create wallet for user
    const wallet = this.walletRepository.create({ user: savedUser });
    await this.walletRepository.save(wallet);

    return this.userRepository.findOne({
      where: { id: savedUser.id },
      relations: ['wallet'],
    });
  }

  async findById(id: string): Promise<User> {
    const user = await this.userRepository.findOne({
      where: { id },
      relations: ['wallet'],
    });
    if (!user) {
      throw new NotFoundException('User not found');
    }
    return user;
  }

  async findByPhoneNumber(phoneNumber: string): Promise<User | null> {
    return this.userRepository.findOne({
      where: { phoneNumber },
      relations: ['wallet'],
    });
  }

  async update(id: string, updateData: Partial<User>): Promise<User> {
    await this.userRepository.update(id, updateData);
    return this.findById(id);
  }

  async updateProfile(id: string, dto: UpdateUserDto): Promise<User> {
    await this.userRepository.update(id, dto);
    return this.findById(id);
  }

  async getWallet(userId: string) {
    const user = await this.findById(userId);
    return user.wallet;
  }
}
