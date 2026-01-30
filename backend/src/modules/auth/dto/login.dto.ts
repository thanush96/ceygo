import { IsNotEmpty, IsString, Matches } from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';

export class LoginDto {
  @ApiProperty({
    description: 'Sri Lankan phone number',
    example: '+94771234567',
    pattern: '^\\+94[0-9]{9}$'
  })
  @IsString()
  @IsNotEmpty()
  @Matches(/^(?:\+94|0)7[0-9]{8}$/, {
    message: 'Mobile number must be a valid Sri Lankan format (e.g., +94771234567 or 0771234567)',
  })
  phone: string;
}
