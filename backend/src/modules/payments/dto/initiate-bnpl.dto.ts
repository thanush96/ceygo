import { IsString, IsNumber, IsOptional, Min } from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';

export class InitiateBnplDto {
  @ApiProperty({ description: 'Booking ID' })
  @IsString()
  bookingId: string;

  @ApiProperty({ description: 'Number of installments (3, 6, 9, or 12)' })
  @IsNumber()
  @Min(3)
  installmentCount: number;

  @ApiProperty({ description: 'BNPL provider', required: false })
  @IsString()
  @IsOptional()
  provider?: string;
}
