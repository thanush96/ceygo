import {
  Controller,
  Post,
  UseGuards,
  UseInterceptors,
  UploadedFiles,
  Request,
  BadRequestException,
} from '@nestjs/common';
import { FilesInterceptor } from '@nestjs/platform-express';
import { ApiTags, ApiOperation, ApiResponse, ApiBearerAuth, ApiConsumes } from '@nestjs/swagger';
import { SkipThrottle } from '@nestjs/throttler';
import { JwtAuthGuard } from '@modules/auth/guards/jwt-auth.guard';
import { RolesGuard } from '@modules/auth/guards/roles.guard';
import { Roles } from '@common/decorators/roles.decorator';
import { UploadService } from './upload.service';

@ApiTags('Upload')
@Controller('upload')
@UseGuards(JwtAuthGuard)
@ApiBearerAuth()
@SkipThrottle()
export class UploadController {
  constructor(private readonly uploadService: UploadService) {}

  @Post('vehicle-images')
  @UseGuards(RolesGuard)
  @Roles('owner', 'admin')
  @ApiOperation({ summary: 'Upload up to 5 vehicle images (compressed to WebP)' })
  @ApiConsumes('multipart/form-data')
  @ApiResponse({ status: 201, description: 'Image URLs returned' })
  @UseInterceptors(
    FilesInterceptor('images', 5, {
      limits: { fileSize: 10 * 1024 * 1024 }, // 10MB per file
      fileFilter: (_req, file, cb) => {
        if (!file.mimetype.startsWith('image/')) {
          return cb(new BadRequestException('Only image files are allowed'), false);
        }
        cb(null, true);
      },
    }),
  )
  async uploadVehicleImages(
    @Request() req,
    @UploadedFiles() files: Express.Multer.File[],
  ) {
    const urls = await this.uploadService.uploadVehicleImages(req.user.id, files);
    return { urls };
  }
}
