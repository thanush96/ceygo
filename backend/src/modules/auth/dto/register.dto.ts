import { IsEmail, IsEnum, IsNotEmpty, IsOptional, IsString, IsUrl, Matches } from 'class-validator';

export class RegisterDto {
  @IsString()
  @IsNotEmpty()
  name: string;

  @IsEmail()
  @IsNotEmpty()
  email: string;

  @IsString()
  @IsNotEmpty()
  @Matches(/^(?:\+94|0)7[0-9]{8}$/, {
    message: 'Mobile number must be a valid Sri Lankan format (e.g., +94771234567 or 0771234567)',
  })
  phone: string;

  @IsString()
  @IsNotEmpty()
  nationality: string;

  @IsEnum(['NIC', 'Passport'])
  @IsNotEmpty()
  idType: string;

  @IsString()
  @IsNotEmpty()
  @Matches(/^(?:[0-9]{9}[xXvV]|[0-9]{12}|[A-Z][0-9]{7})$/, {
    message: 'Identity number must be a valid NIC or Passport format',
  })
  idNumber: string;

  @IsString()
  @IsNotEmpty()
  licenseNo: string;

  @IsUrl()
  @IsOptional()
  profilePic?: string;

  @IsEnum(['renter', 'owner'])
  @IsOptional()
  role?: string = 'renter';
}
