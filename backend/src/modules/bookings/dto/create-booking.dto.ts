import { IsDateString, IsNotEmpty, IsUUID, IsString, IsOptional } from 'class-validator';
import { Type } from 'class-transformer';

export class CreateBookingDto {
  @IsUUID()
  @IsNotEmpty()
  vehicleId: string;

  @IsDateString()
  @IsNotEmpty()
  startDate: string;

  @IsDateString()
  @IsNotEmpty()
  endDate: string;

  @IsString()
  @IsNotEmpty()
  pickupLocation: string;

  @IsString()
  @IsNotEmpty()
  dropoffLocation: string;

  @IsString()
  @IsOptional()
  flightNumber?: string;
}
