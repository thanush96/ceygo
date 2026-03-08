import {
  Controller,
  Get,
  Post,
  Delete,
  Param,
  UseGuards,
  Request,
} from '@nestjs/common';
import { ApiTags, ApiOperation, ApiResponse, ApiBearerAuth } from '@nestjs/swagger';
import { FavoritesService } from './favorites.service';
import { JwtAuthGuard } from '@modules/auth/guards/jwt-auth.guard';

@ApiTags('Favorites')
@Controller('favorites')
@UseGuards(JwtAuthGuard)
@ApiBearerAuth()
export class FavoritesController {
  constructor(private readonly favoritesService: FavoritesService) {}

  @Get()
  @ApiOperation({ summary: 'Get all favorite vehicles' })
  @ApiResponse({ status: 200, description: 'List of favorite vehicles' })
  getFavorites(@Request() req) {
    return this.favoritesService.getFavorites(req.user.id);
  }

  @Get('ids')
  @ApiOperation({ summary: 'Get favorite vehicle IDs' })
  @ApiResponse({ status: 200, description: 'List of favorite vehicle IDs' })
  getFavoriteIds(@Request() req) {
    return this.favoritesService.getFavoriteIds(req.user.id);
  }

  @Post(':vehicleId')
  @ApiOperation({ summary: 'Add vehicle to favorites' })
  @ApiResponse({ status: 201, description: 'Vehicle added to favorites' })
  addFavorite(@Request() req, @Param('vehicleId') vehicleId: string) {
    return this.favoritesService.addFavorite(req.user.id, vehicleId);
  }

  @Delete(':vehicleId')
  @ApiOperation({ summary: 'Remove vehicle from favorites' })
  @ApiResponse({ status: 200, description: 'Vehicle removed from favorites' })
  removeFavorite(@Request() req, @Param('vehicleId') vehicleId: string) {
    return this.favoritesService.removeFavorite(req.user.id, vehicleId);
  }
}
