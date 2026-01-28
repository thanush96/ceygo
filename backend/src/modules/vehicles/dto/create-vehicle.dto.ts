import { ApiProperty } from '@nestjs/swagger';
import {
  IsNotEmpty,
  IsString,
  IsNumber,
  IsOptional,
  IsBoolean,
  Min,
  Max,
} from 'class-validator';

export class CreateVehicleDto {
  @ApiProperty()
  @IsNotEmpty()
  @IsString()
  make: string;

  @ApiProperty()
  @IsNotEmpty()
  @IsString()
  model: string;

  @ApiProperty()
  @IsNotEmpty()
  @IsNumber()
  @Min(1900)
  @Max(new Date().getFullYear() + 1)
  year: number;

  @ApiProperty()
  @IsNotEmpty()
  @IsString()
  color: string;

  @ApiProperty()
  @IsNotEmpty()
  @IsString()
  licensePlate: string;

  @ApiProperty()
  @IsNotEmpty()
  @IsString()
  vin: string;

  @ApiProperty()
  @IsNotEmpty()
  @IsNumber()
  @Min(0)
  pricePerDay: number;

  @ApiProperty({ required: false })
  @IsOptional()
  @IsNumber()
  @Min(0)
  pricePerHour?: number;

  @ApiProperty({ required: false })
  @IsOptional()
  @IsNumber()
  @Min(0)
  pricePerWeek?: number;

  @ApiProperty({ required: false })
  @IsOptional()
  @IsNumber()
  @Min(0)
  pricePerMonth?: number;

  @ApiProperty()
  @IsNotEmpty()
  @IsNumber()
  @Min(1)
  seats: number;

  @ApiProperty()
  @IsNotEmpty()
  @IsString()
  transmission: string;

  @ApiProperty()
  @IsNotEmpty()
  @IsString()
  fuelType: string;

  @ApiProperty({ required: false })
  @IsOptional()
  @IsString()
  description?: string;

  @ApiProperty({ required: false })
  @IsOptional()
  @IsString()
  location?: string;

  @ApiProperty({ required: false })
  @IsOptional()
  @IsNumber()
  latitude?: number;

  @ApiProperty({ required: false })
  @IsOptional()
  @IsNumber()
  longitude?: number;

  @ApiProperty({ required: false })
  @IsOptional()
  @IsString()
  insuranceNumber?: string;

  @ApiProperty({ required: false })
  @IsOptional()
  @IsString()
  insuranceExpiryDate?: string;

  @ApiProperty({ required: false })
  @IsOptional()
  @IsString()
  registrationExpiryDate?: string;
}
