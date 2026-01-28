import { ApiProperty } from '@nestjs/swagger';
import { UserRole } from '../../../common/enums/user-role.enum';

export class AuthResponseDto {
  @ApiProperty()
  accessToken: string;

  @ApiProperty()
  refreshToken: string;

  @ApiProperty()
  user: {
    id: string;
    phoneNumber: string;
    firstName: string;
    lastName: string;
    email?: string;
    role: UserRole;
    isVerified: boolean;
  };
}
