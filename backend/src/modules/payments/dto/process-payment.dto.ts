import { ApiProperty } from '@nestjs/swagger';
import { IsNotEmpty, IsString, IsEnum, IsOptional } from 'class-validator';
import { PaymentMethod } from '../../../common/enums/payment-method.enum';

export class ProcessPaymentDto {
  @ApiProperty()
  @IsNotEmpty()
  @IsString()
  bookingId: string;

  @ApiProperty({ enum: PaymentMethod })
  @IsNotEmpty()
  @IsEnum(PaymentMethod)
  method: PaymentMethod;

  @ApiProperty({ required: false })
  @IsOptional()
  @IsString()
  cardToken?: string;

  @ApiProperty({ required: false })
  @IsOptional()
  @IsString()
  walletPin?: string;
}
