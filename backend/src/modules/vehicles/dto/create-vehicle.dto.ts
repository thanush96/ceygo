import { IsString, IsNumber, IsOptional, IsNotEmpty, IsEnum, IsUrl, IsBoolean, Matches, Min, Max } from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';

export class CreateVehicleDto {
  @ApiProperty({ example: 'Toyota start Prius 2024' })
  @IsString()
  @IsNotEmpty()
  name: string;

  @ApiProperty({ example: 'Toyota' })
  @IsString()
  @IsNotEmpty()
  brand: string;

  @ApiProperty({ required: false, example: 'https://example.com/logo.png' })
  @IsUrl()
  @IsOptional()
  brandLogo?: string;

  @ApiProperty({ required: false, example: 'https://example.com/car.jpg' })
  @IsUrl()
  @IsOptional()
  @Matches(/\.(jpg|jpeg|png|webp)$/i, { message: 'Image must be a valid JPG, PNG or WEBP file' })
  imageUrl?: string;

  @ApiProperty({ example: 5000, description: 'Price per day in LKR' })
  @IsNumber()
  @IsNotEmpty()
  @Min(0)
  pricePerDay: number;

  @ApiProperty({ example: 5 })
  @IsNumber()
  @IsNotEmpty()
  @Min(1)
  seats: number;

  @ApiProperty({ enum: ['Manual', 'Auto'], example: 'Auto' })
  @IsEnum(['Manual', 'Auto'])
  @IsNotEmpty()
  transmission: string;

  @ApiProperty({ enum: ['Petrol', 'Diesel', 'Electric', 'Hybrid'], example: 'Hybrid' })
  @IsEnum(['Petrol', 'Diesel', 'Electric', 'Hybrid'])
  @IsNotEmpty()
  fuelType: string;

  @ApiProperty({ example: 'WP CAB-1234' })
  @IsString()
  @IsNotEmpty()
  @Matches(/^(?:[A-Z]{1,3}-[0-9]{4}|[0-9]{1,3}-[0-9]{4})$/, {
    message: 'Plate number must be a valid Sri Lankan format (e.g., WP CAB-1234 or 15-1234)',
  })
  plateNo: string;

  @ApiProperty({ required: false, default: false })
  @IsBoolean()
  @IsOptional()
  airportPickupAvailable?: boolean = false;

  @ApiProperty({ required: false, example: 'Colombo' })
  @IsString()
  @IsOptional()
  location?: string;

  @ApiProperty({ required: false, example: 6.9271 })
  @IsNumber()
  @IsOptional()
  lat?: number;

  @ApiProperty({ required: false, example: 79.8612 })
  @IsNumber()
  @IsOptional()
  lng?: number;
}
