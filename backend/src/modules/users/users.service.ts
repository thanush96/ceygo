import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@mikro-orm/nestjs';
import { EntityRepository, EntityManager } from '@mikro-orm/postgresql';
import { User } from './entities/user.entity';

@Injectable()
export class UsersService {
  constructor(
    @InjectRepository(User)
    private readonly userRepository: EntityRepository<User>,
    private readonly em: EntityManager,
  ) {}

  async getUserById(id: string): Promise<User> {
    const user = await this.userRepository.findOne({ id });
    if (!user) throw new NotFoundException('User not found');
    return user;
  }

  async switchRole(userId: string, role: 'renter' | 'owner'): Promise<User> {
    const user = await this.getUserById(userId);
    user.role = role;
    await this.em.flush();
    return user;
  }

  async updateProfile(userId: string, data: Partial<Pick<User, 'name' | 'profilePic'>>): Promise<User> {
    const user = await this.getUserById(userId);
    Object.assign(user, data);
    await this.em.flush();
    return user;
  }
}
