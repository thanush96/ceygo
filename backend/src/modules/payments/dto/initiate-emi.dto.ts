import { IsString, IsNumber, Min, Max } from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';

export class InitiateEmiDto {
  @ApiProperty({ description: 'Booking ID' })
  @IsString()
  bookingId: string;

  @ApiProperty({ description: 'Bank name' })
  @IsString()
  bankName: string;

  @ApiProperty({ description: 'Tenure in months' })
  @IsNumber()
  @Min(3)
  @Max(24)
  tenureMonths: number;
}
