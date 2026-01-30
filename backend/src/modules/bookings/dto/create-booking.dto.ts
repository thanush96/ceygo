import { IsDateString, IsNotEmpty, IsUUID, IsString, IsOptional } from 'class-validator';
import { Type } from 'class-transformer';
import { ApiProperty } from '@nestjs/swagger';

export class CreateBookingDto {
  @ApiProperty({ example: 'uuid-v4-id' })
  @IsUUID()
  @IsNotEmpty()
  vehicleId: string;

  @ApiProperty({ example: '2026-02-10T10:00:00Z' })
  @IsDateString()
  @IsNotEmpty()
  startDate: string;

  @ApiProperty({ example: '2026-02-12T10:00:00Z' })
  @IsDateString()
  @IsNotEmpty()
  endDate: string;

  @ApiProperty({ example: 'Colombo Fort' })
  @IsString()
  @IsNotEmpty()
  pickupLocation: string;

  @ApiProperty({ example: 'Kandy' })
  @IsString()
  @IsNotEmpty()
  dropoffLocation: string;

  @ApiProperty({ required: false, example: 'UL123' })
  @IsString()
  @IsOptional()
  flightNumber?: string;
}
