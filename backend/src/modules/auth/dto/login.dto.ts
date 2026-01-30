import { IsNotEmpty, IsString, Matches } from 'class-validator';

export class LoginDto {
  @IsString()
  @IsNotEmpty()
  @Matches(/^(?:\+94|0)7[0-9]{8}$/, {
    message: 'Mobile number must be a valid Sri Lankan format (e.g., +94771234567 or 0771234567)',
  })
  phone: string;
}
