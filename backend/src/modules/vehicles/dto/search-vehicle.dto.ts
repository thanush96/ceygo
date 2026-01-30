import { IsOptional, IsString, IsNumber, IsEnum, IsDateString, Min } from 'class-validator';
import { Type } from 'class-transformer';
import { ApiProperty } from '@nestjs/swagger';

export class SearchVehicleDto {
  @ApiProperty({ required: false, example: 'Colombo' })
  @IsString()
  @IsOptional()
  location?: string;

  @ApiProperty({ required: false, enum: ['Petrol', 'Diesel', 'Electric', 'Hybrid'] })
  @IsEnum(['Petrol', 'Diesel', 'Electric', 'Hybrid'])
  @IsOptional()
  fuelType?: string;

  @ApiProperty({ required: false, enum: ['Manual', 'Auto'] })
  @IsEnum(['Manual', 'Auto'])
  @IsOptional()
  transmission?: string;

  @ApiProperty({ required: false, example: 5000 })
  @IsNumber()
  @IsOptional()
  @Type(() => Number)
  minPrice?: number;

  @ApiProperty({ required: false, example: 10000 })
  @IsNumber()
  @IsOptional()
  @Type(() => Number)
  maxPrice?: number;

  @ApiProperty({ required: false, example: 4 })
  @IsNumber()
  @IsOptional()
  @Type(() => Number)
  seats?: number;

  @ApiProperty({ required: false, example: '2026-02-10' })
  @IsDateString()
  @IsOptional()
  startDate?: string;

  @ApiProperty({ required: false, example: '2026-02-15' })
  @IsDateString()
  @IsOptional()
  endDate?: string;

  @ApiProperty({ required: false, default: 1 })
  @IsOptional()
  @IsNumber()
  @Min(1)
  @Type(() => Number)
  page?: number = 1;

  @ApiProperty({ required: false, default: 20 })
  @IsOptional()
  @IsNumber()
  @Min(1)
  @Type(() => Number)
  limit?: number = 20;

  @ApiProperty({ required: false, default: 'createdAt' })
  @IsOptional()
  @IsString()
  sortBy?: string = 'createdAt';

  @ApiProperty({ required: false, enum: ['ASC', 'DESC'], default: 'DESC' })
  @IsOptional()
  @IsEnum(['ASC', 'DESC'])
  sortOrder?: 'ASC' | 'DESC' = 'DESC';
}
