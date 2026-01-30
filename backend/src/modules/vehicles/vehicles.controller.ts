import {
  Controller,
  Get,
  Post,
  Body,
  Param,
  Patch,
  Delete,
  Query,
  UseGuards,
  Request,
} from '@nestjs/common';
import { Throttle } from '@nestjs/throttler';
import { CacheTTL } from '@common/decorators/cache-ttl.decorator';
import { VehiclesService } from './vehicles.service';
import { CreateVehicleDto } from './dto/create-vehicle.dto';
import { UpdateVehicleDto } from './dto/update-vehicle.dto';
import { SearchVehicleDto } from './dto/search-vehicle.dto';
import { JwtAuthGuard } from '@modules/auth/guards/jwt-auth.guard';
import { RolesGuard } from '@modules/auth/guards/roles.guard';
import { Roles } from '@common/decorators/roles.decorator';

@Controller('vehicles')
export class VehiclesController {
  constructor(private readonly vehiclesService: VehiclesService) {}

  @Post()
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles('owner', 'admin')
  create(@Request() req, @Body() createVehicleDto: CreateVehicleDto) {
    return this.vehiclesService.createVehicle(req.user.id, createVehicleDto);
  }

  @Get()
  @Throttle({ search: { limit: 60, ttl: 60000 } })
  @CacheTTL(3600000) // 1 hour cache
  search(@Query() searchDto: SearchVehicleDto) {
    return this.vehiclesService.searchVehicles(searchDto);
  }

  @Get('owner/me')
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles('owner')
  getOwnerVehicles(@Request() req) {
    return this.vehiclesService.getOwnerVehicles(req.user.id);
  }

  @Get(':id')
  findOne(@Param('id') id: string) {
    return this.vehiclesService.getVehicleById(id);
  }

  @Get(':id/availability')
  checkAvailability(
    @Param('id') id: string,
    @Query('start') start: string,
    @Query('end') end: string,
  ) {
    return this.vehiclesService.checkAvailability(id, start, end);
  }

  @Patch(':id')
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles('owner', 'admin')
  update(
    @Param('id') id: string,
    @Request() req,
    @Body() updateVehicleDto: UpdateVehicleDto,
  ) {
    return this.vehiclesService.updateVehicle(id, req.user.id, updateVehicleDto);
  }

  @Delete(':id')
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles('owner', 'admin')
  remove(@Param('id') id: string, @Request() req) {
    return this.vehiclesService.deleteVehicle(id, req.user.id);
  }
}
