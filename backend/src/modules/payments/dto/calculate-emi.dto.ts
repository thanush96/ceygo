import { IsString, IsNumber, Min, Max } from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';

export class CalculateEmiDto {
  @ApiProperty({ description: 'Principal amount' })
  @IsNumber()
  @Min(1000)
  amount: number;

  @ApiProperty({ description: 'Bank name' })
  @IsString()
  bankName: string;

  @ApiProperty({ description: 'Tenure in months' })
  @IsNumber()
  @Min(3)
  @Max(24)
  tenureMonths: number;
}
