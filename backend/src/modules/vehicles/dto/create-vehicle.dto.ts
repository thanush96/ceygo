import { IsString, IsNumber, IsOptional, IsNotEmpty, IsEnum, IsUrl, IsBoolean, Matches, Min, Max } from 'class-validator';

export class CreateVehicleDto {
  @IsString()
  @IsNotEmpty()
  name: string;

  @IsString()
  @IsNotEmpty()
  brand: string;

  @IsUrl()
  @IsOptional()
  brandLogo?: string;

  @IsUrl()
  @IsOptional()
  @Matches(/\.(jpg|jpeg|png|webp)$/i, { message: 'Image must be a valid JPG, PNG or WEBP file' })
  imageUrl?: string;

  @IsNumber()
  @IsNotEmpty()
  @Min(0)
  pricePerDay: number;

  @IsNumber()
  @IsNotEmpty()
  @Min(1)
  seats: number;

  @IsEnum(['Manual', 'Auto'])
  @IsNotEmpty()
  transmission: string;

  @IsEnum(['Petrol', 'Diesel', 'Electric', 'Hybrid'])
  @IsNotEmpty()
  fuelType: string;

  @IsString()
  @IsNotEmpty()
  @Matches(/^(?:[A-Z]{1,3}-[0-9]{4}|[0-9]{1,3}-[0-9]{4})$/, {
    message: 'Plate number must be a valid Sri Lankan format (e.g., WP CAB-1234 or 15-1234)',
  })
  plateNo: string;

  @IsBoolean()
  @IsOptional()
  airportPickupAvailable?: boolean = false;

  @IsString()
  @IsOptional()
  location?: string;

  @IsNumber()
  @IsOptional()
  lat?: number;

  @IsNumber()
  @IsOptional()
  lng?: number;
}
