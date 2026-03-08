import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@mikro-orm/nestjs';
import { EntityRepository, EntityManager } from '@mikro-orm/postgresql';
import { Favorite } from './entities/favorite.entity';

@Injectable()
export class FavoritesService {
  constructor(
    @InjectRepository(Favorite)
    private readonly favoriteRepository: EntityRepository<Favorite>,
    private readonly em: EntityManager,
  ) {}

  async getFavorites(userId: string) {
    const favorites = await this.favoriteRepository.find(
      { user: userId },
      {
        populate: ['vehicle'] as any,
        orderBy: { createdAt: 'DESC' },
      },
    );

    return favorites
      .filter((f: any) => f.vehicle && !f.vehicle.deletedAt)
      .map((f: any) => f.vehicle);
  }

  async getFavoriteIds(userId: string): Promise<string[]> {
    const favorites = await this.favoriteRepository.find(
      { user: userId },
      { fields: ['vehicle'] },
    );
    return favorites.map((f: any) => f.vehicle.id ?? f.vehicle);
  }

  async addFavorite(userId: string, vehicleId: string) {
    const existing = await this.favoriteRepository.findOne({
      user: userId,
      vehicle: vehicleId,
    });

    if (existing) {
      return { message: 'Already in favorites' };
    }

    const favorite = this.favoriteRepository.create({
      user: userId,
      vehicle: vehicleId,
    });

    await this.em.persistAndFlush(favorite);
    return { message: 'Added to favorites' };
  }

  async removeFavorite(userId: string, vehicleId: string) {
    const favorite = await this.favoriteRepository.findOne({
      user: userId,
      vehicle: vehicleId,
    });

    if (!favorite) {
      throw new NotFoundException('Favorite not found');
    }

    await this.em.removeAndFlush(favorite);
    return { message: 'Removed from favorites' };
  }

  async isFavorite(userId: string, vehicleId: string): Promise<boolean> {
    const count = await this.favoriteRepository.count({
      user: userId,
      vehicle: vehicleId,
    });
    return count > 0;
  }
}
