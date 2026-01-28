import { ApiProperty } from '@nestjs/swagger';
import { IsNotEmpty, IsString, IsOptional, IsDateString } from 'class-validator';

export class CreateDriverDto {
  @ApiProperty()
  @IsNotEmpty()
  @IsString()
  licenseNumber: string;

  @ApiProperty()
  @IsNotEmpty()
  @IsDateString()
  licenseExpiryDate: string;

  @ApiProperty({ required: false })
  @IsOptional()
  @IsString()
  licenseImage?: string;

  @ApiProperty()
  @IsNotEmpty()
  @IsString()
  nationalId: string;

  @ApiProperty({ required: false })
  @IsOptional()
  @IsString()
  nationalIdImage?: string;

  @ApiProperty({ required: false })
  @IsOptional()
  @IsString()
  bankName?: string;

  @ApiProperty({ required: false })
  @IsOptional()
  @IsString()
  bankAccountNumber?: string;

  @ApiProperty({ required: false })
  @IsOptional()
  @IsString()
  bankAccountHolderName?: string;

  @ApiProperty({ required: false })
  @IsOptional()
  @IsString()
  bankBranch?: string;
}
