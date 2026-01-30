import { Injectable, UnauthorizedException, BadRequestException } from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import { ConfigService } from '@nestjs/config';
import { EntityManager } from '@mikro-orm/postgresql';
import { User } from '@modules/users/entities/user.entity';
import { OtpService } from './otp.service';
import { VerifyOtpDto } from './dto/verify-otp.dto';
import { RegisterDto } from './dto/register.dto';
import { AuditService } from '@common/services/audit.service';

@Injectable()
export class AuthService {
  // Simple in-memory OTP storage for demonstration. 
  // In production, use Redis as configured in .env
  private otpStore = new Map<string, { otp: string; expires: number }>();

  constructor(
    private readonly em: EntityManager,
    private readonly jwtService: JwtService,
    private readonly configService: ConfigService,
    private readonly otpService: OtpService,
    private readonly auditService: AuditService,
  ) {}

  async sendLoginOtp(phone: string) {
    const otp = this.otpService.generateOtp();
    const expiresAt = Date.now() + (this.configService.get<number>('OTP_EXPIRES_IN') || 300) * 1000;
    
    this.otpStore.set(phone, { otp, expires: expiresAt });
    
    const sent = await this.otpService.sendOtp(phone, otp);
    if (!sent) {
      throw new BadRequestException('Failed to send OTP');
    }

    return { message: 'OTP sent successfully' };
  }

  async verifyOtp(verifyOtpDto: VerifyOtpDto) {
    const { phone, otp } = verifyOtpDto;
    const stored = this.otpStore.get(phone);

    if (!stored || stored.otp !== otp || stored.expires < Date.now()) {
      this.auditService.logAction('UNKNOWN', 'AUTH_OTP_FAILURE', { phone });
      throw new UnauthorizedException('Invalid or expired OTP');
    }

    this.otpStore.delete(phone);

    let user = await this.em.findOne(User, { phone });
    
    if (!user) {
      return { isNewUser: true, phone };
    }

    const tokens = await this.generateTokens(user);
    this.auditService.logAction(user.id, 'AUTH_LOGIN_SUCCESS', { phone });
    return { isNewUser: false, user, ...tokens };
  }

  async register(registerDto: RegisterDto) {
    const existingUser = await this.em.findOne(User, {
      $or: [{ email: registerDto.email }, { phone: registerDto.phone }, { nic: registerDto.idNumber }],
    });

    if (existingUser) {
      throw new BadRequestException('User with this email, phone, or NIC already exists');
    }

    const user = this.em.create(User, {
      ...registerDto,
      nic: registerDto.idNumber, // Map idNumber to nic in entity
    });

    await this.em.persistAndFlush(user);
    
    const tokens = await this.generateTokens(user);
    return { user, ...tokens };
  }

  async validateGoogleUser(googleProfile: any) {
    let user = await this.em.findOne(User, { email: googleProfile.email });

    if (!user) {
      // Create a basic profile for international users
      user = this.em.create(User, {
        name: `${googleProfile.firstName} ${googleProfile.lastName}`,
        email: googleProfile.email,
        phone: 'N/A', // Placeholder for OAuth users
        nationality: 'International',
        idType: 'Passport',
        nic: `OAUTH_${googleProfile.id}`, // Placeholder
        licenseNo: 'N/A',
        profilePic: googleProfile.picture,
        role: 'renter',
      });
      await this.em.persistAndFlush(user);
    }

    return this.generateTokens(user);
  }

  async generateTokens(user: User) {
    const payload = { sub: user.id, email: user.email, role: user.role };
    
    const accessToken = this.jwtService.sign(payload, {
      secret: this.configService.get('JWT_SECRET'),
      expiresIn: '24h',
    });

    const refreshToken = this.jwtService.sign(payload, {
      secret: this.configService.get('JWT_REFRESH_SECRET'),
      expiresIn: this.configService.get('JWT_REFRESH_EXPIRES_IN') || '30d',
    });

    return {
      accessToken,
      refreshToken,
    };
  }

  async refreshToken(token: string) {
    try {
      const payload = this.jwtService.verify(token, {
        secret: this.configService.get('JWT_REFRESH_SECRET'),
      });
      
      const user = await this.em.findOne(User, { id: payload.sub });
      if (!user) {
        throw new UnauthorizedException();
      }

      return this.generateTokens(user);
    } catch (e) {
      throw new UnauthorizedException('Invalid refresh token');
    }
  }
}
