import { IsEmail, IsEnum, IsNotEmpty, IsOptional, IsString, IsUrl, Matches } from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';

export class RegisterDto {
  @ApiProperty({ example: 'John Doe', description: 'Full Name' })
  @IsString()
  @IsNotEmpty()
  name: string;

  @ApiProperty({ example: 'john@example.com', description: 'User Email' })
  @IsEmail()
  @IsNotEmpty()
  email: string;

  @ApiProperty({ example: '+94771234567', description: 'Sri Lankan Mobile Number' })
  @IsString()
  @IsNotEmpty()
  @Matches(/^(?:\+94|0)7[0-9]{8}$/, {
    message: 'Mobile number must be a valid Sri Lankan format (e.g., +94771234567 or 0771234567)',
  })
  phone: string;

  @ApiProperty({ example: 'Sri Lankan', description: 'User Nationality' })
  @IsString()
  @IsNotEmpty()
  nationality: string;

  @ApiProperty({ example: 'NIC', enum: ['NIC', 'Passport'], description: 'ID Type' })
  @IsEnum(['NIC', 'Passport'])
  @IsNotEmpty()
  idType: string;

  @ApiProperty({ example: '199012345678', description: 'NIC or Passport Number' })
  @IsString()
  @IsNotEmpty()
  @Matches(/^(?:[0-9]{9}[xXvV]|[0-9]{12}|[A-Z][0-9]{7})$/, {
    message: 'Identity number must be a valid NIC or Passport format',
  })
  idNumber: string;

  @ApiProperty({ example: 'B1234567', description: 'Driving License Number' })
  @IsString()
  @IsNotEmpty()
  licenseNo: string;

  @ApiProperty({ required: false, example: 'https://example.com/pic.jpg' })
  @IsUrl()
  @IsOptional()
  profilePic?: string;

  @ApiProperty({ required: false, enum: ['renter', 'owner'], default: 'renter' })
  @IsEnum(['renter', 'owner'])
  @IsOptional()
  role?: string = 'renter';
}
