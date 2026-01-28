import {
  Controller,
  Get,
  Post,
  Put,
  Delete,
  Body,
  Param,
  Query,
  UseGuards,
} from '@nestjs/common';
import { ApiTags, ApiOperation, ApiBearerAuth, ApiQuery } from '@nestjs/swagger';
import { VehiclesService } from './vehicles.service';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { CurrentUser } from '../auth/decorators/current-user.decorator';
import { User } from '../users/entities/user.entity';
import { CreateVehicleDto } from './dto/create-vehicle.dto';
import { UpdateVehicleDto } from './dto/update-vehicle.dto';
import { SearchVehiclesDto } from './dto/search-vehicles.dto';

@ApiTags('vehicles')
@Controller('vehicles')
export class VehiclesController {
  constructor(private readonly vehiclesService: VehiclesService) {}

  @Get()
  @ApiOperation({ summary: 'Search and list vehicles' })
  async findAll(@Query() dto: SearchVehiclesDto) {
    return this.vehiclesService.findAll(dto);
  }

  @Get(':id')
  @ApiOperation({ summary: 'Get vehicle details' })
  async findOne(@Param('id') id: string) {
    return this.vehiclesService.findOne(id);
  }

  @Post()
  @ApiBearerAuth()
  @UseGuards(JwtAuthGuard)
  @ApiOperation({ summary: 'Register a new vehicle (Driver only)' })
  async create(
    @CurrentUser() user: User,
    @Body() dto: CreateVehicleDto,
  ) {
    return this.vehiclesService.create(user.id, dto);
  }

  @Get('driver/my-vehicles')
  @ApiBearerAuth()
  @UseGuards(JwtAuthGuard)
  @ApiOperation({ summary: 'Get my vehicles (Driver only)' })
  async getMyVehicles(@CurrentUser() user: User) {
    return this.vehiclesService.findByDriver(user.id);
  }

  @Put(':id')
  @ApiBearerAuth()
  @UseGuards(JwtAuthGuard)
  @ApiOperation({ summary: 'Update vehicle (Owner only)' })
  async update(
    @Param('id') id: string,
    @CurrentUser() user: User,
    @Body() dto: UpdateVehicleDto,
  ) {
    return this.vehiclesService.update(id, user.id, dto);
  }
}
