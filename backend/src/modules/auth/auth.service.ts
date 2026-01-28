import { Injectable, UnauthorizedException, BadRequestException } from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import { ConfigService } from '@nestjs/config';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Inject } from '@nestjs/common';
import { Otp } from './entities/otp.entity';
import { UsersService } from '../users/users.service';
import { SendOtpDto } from './dto/send-otp.dto';
import { VerifyOtpDto } from './dto/verify-otp.dto';
import { RegisterDto } from './dto/register.dto';
import { AuthResponseDto } from './dto/auth-response.dto';

@Injectable()
export class AuthService {
  constructor(
    @InjectRepository(Otp)
    private otpRepository: Repository<Otp>,
    private usersService: UsersService,
    private jwtService: JwtService,
    private configService: ConfigService,
    @Inject('REDIS_CLIENT') private redis: any,
  ) {}

  async sendOtp(dto: SendOtpDto): Promise<{ message: string; expiresIn: number; retryAfter?: number }> {
    // Rate limiting check
    const rateLimitKey = `otp_rate:${dto.phoneNumber}`;
    const attempts = await this.redis.incr(rateLimitKey);
    
    if (attempts === 1) {
      await this.redis.expire(rateLimitKey, 300); // 5 minutes window
    }
    
    if (attempts > 5) {
      const ttl = await this.redis.ttl(rateLimitKey);
      throw new BadRequestException('Too many OTP requests. Please try again later.');
    }

    const code = this.generateOtp();
    const expiresIn = parseInt(this.configService.get<string>('OTP_EXPIRES_IN', '300'));

    // Store in database
    const otp = this.otpRepository.create({
      phoneNumber: dto.phoneNumber,
      code,
      expiresAt: new Date(Date.now() + expiresIn * 1000),
    });
    await this.otpRepository.save(otp);

    // Also cache in Redis for faster verification
    await this.redis.setex(
      `otp:${dto.phoneNumber}`,
      expiresIn,
      JSON.stringify({ code, expiresAt: otp.expiresAt }),
    );

    // TODO: Integrate with SMS gateway (Twilio, AWS SNS, etc.)
    console.log(`OTP for ${dto.phoneNumber}: ${code}`); // Remove in production

    return {
      message: 'OTP sent successfully',
      expiresIn,
      retryAfter: attempts < 5 ? undefined : 60, // seconds until next attempt
    };
  }

  async verifyOtp(dto: VerifyOtpDto): Promise<AuthResponseDto> {
    // Check Redis first
    const cachedOtp = await this.redis.get(`otp:${dto.phoneNumber}`);
    let otp: Otp | null = null;

    if (cachedOtp) {
      const parsed = JSON.parse(cachedOtp);
      if (parsed.code === dto.code && new Date(parsed.expiresAt) > new Date()) {
        otp = await this.otpRepository.findOne({
          where: { phoneNumber: dto.phoneNumber, code: dto.code, isUsed: false },
        });
      }
    } else {
      otp = await this.otpRepository.findOne({
        where: { phoneNumber: dto.phoneNumber, code: dto.code, isUsed: false },
      });
    }

    if (!otp || otp.expiresAt < new Date()) {
      throw new UnauthorizedException('Invalid or expired OTP');
    }

    // Mark OTP as used
    otp.isUsed = true;
    otp.usedAt = new Date();
    await this.otpRepository.save(otp);
    await this.redis.del(`otp:${dto.phoneNumber}`);

    // Get or create user
    let user = await this.usersService.findByPhoneNumber(dto.phoneNumber);
    if (!user) {
      // Auto-register user if not exists
      const registerDto: RegisterDto = {
        phoneNumber: dto.phoneNumber,
        firstName: 'User',
        lastName: '',
      };
      user = await this.usersService.create(registerDto);
    }

    // Update last login
    user.lastLoginAt = new Date();
    await this.usersService.update(user.id, { lastLoginAt: user.lastLoginAt });

    // Generate tokens
    const tokens = await this.generateTokens(user.id, user.role);

    return {
      ...tokens,
      user: {
        id: user.id,
        phoneNumber: user.phoneNumber,
        firstName: user.firstName,
        lastName: user.lastName,
        email: user.email,
        role: user.role,
        isVerified: user.isVerified,
      },
    };
  }

  async register(dto: RegisterDto): Promise<AuthResponseDto> {
    const existingUser = await this.usersService.findByPhoneNumber(dto.phoneNumber);
    if (existingUser) {
      throw new BadRequestException('User already exists');
    }

    const user = await this.usersService.create(dto);
    const tokens = await this.generateTokens(user.id, user.role);

    return {
      ...tokens,
      user: {
        id: user.id,
        phoneNumber: user.phoneNumber,
        firstName: user.firstName,
        lastName: user.lastName,
        email: user.email,
        role: user.role,
        isVerified: user.isVerified,
      },
    };
  }

  async refreshToken(refreshToken: string): Promise<{ accessToken: string }> {
    try {
      const payload = await this.jwtService.verifyAsync(refreshToken, {
        secret: this.configService.get<string>('JWT_REFRESH_SECRET'),
      });

      const user = await this.usersService.findById(payload.sub);
      if (!user || !user.isActive) {
        throw new UnauthorizedException('User not found or inactive');
      }

      const accessToken = this.jwtService.sign(
        { sub: user.id, role: user.role },
        {
          secret: this.configService.get<string>('JWT_SECRET'),
          expiresIn: this.configService.get<string>('JWT_EXPIRES_IN', '7d'),
        },
      );

      return { accessToken };
    } catch (error) {
      throw new UnauthorizedException('Invalid refresh token');
    }
  }

  private async generateTokens(userId: string, role: string) {
    const payload = { sub: userId, role };

    const accessToken = this.jwtService.sign(payload, {
      secret: this.configService.get<string>('JWT_SECRET'),
      expiresIn: this.configService.get<string>('JWT_EXPIRES_IN', '7d'),
    });

    const refreshToken = this.jwtService.sign(payload, {
      secret: this.configService.get<string>('JWT_REFRESH_SECRET'),
      expiresIn: this.configService.get<string>('JWT_REFRESH_EXPIRES_IN', '30d'),
    });

    return { accessToken, refreshToken };
  }

  private generateOtp(): string {
    const length = parseInt(this.configService.get<string>('OTP_LENGTH', '6'));
    const digits = '0123456789';
    let otp = '';
    for (let i = 0; i < length; i++) {
      otp += digits[Math.floor(Math.random() * digits.length)];
    }
    return otp;
  }
}
