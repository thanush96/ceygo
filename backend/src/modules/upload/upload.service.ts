import { Injectable, BadRequestException } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { S3Client, PutObjectCommand, DeleteObjectCommand } from '@aws-sdk/client-s3';
import * as sharp from 'sharp';
import { v4 } from 'uuid';

@Injectable()
export class UploadService {
  private s3: S3Client;
  private bucket: string;
  private region: string;

  constructor(private readonly configService: ConfigService) {
    this.region = this.configService.get<string>('AWS_S3_REGION', 'ap-south-1');
    this.bucket = this.configService.get<string>('AWS_S3_BUCKET', '');

    this.s3 = new S3Client({
      region: this.region,
      credentials: {
        accessKeyId: this.configService.get<string>('AWS_ACCESS_KEY_ID', ''),
        secretAccessKey: this.configService.get<string>('AWS_SECRET_ACCESS_KEY', ''),
      },
    });
  }

  async uploadVehicleImages(
    ownerId: string,
    files: Express.Multer.File[],
  ): Promise<string[]> {
    if (!files || files.length === 0) {
      throw new BadRequestException('No files provided');
    }
    if (files.length > 5) {
      throw new BadRequestException('Maximum 5 images allowed');
    }

    const urls: string[] = [];

    for (const file of files) {
      // Validate file type
      if (!file.mimetype.startsWith('image/')) {
        throw new BadRequestException(`Invalid file type: ${file.originalname}`);
      }

      // Compress with sharp: resize to max 1200px wide, quality 80, WebP
      const compressed = await sharp(file.buffer)
        .resize(1200, 800, { fit: 'inside', withoutEnlargement: true })
        .webp({ quality: 80 })
        .toBuffer();

      const key = `vehicles/${ownerId}/${v4()}.webp`;

      await this.s3.send(
        new PutObjectCommand({
          Bucket: this.bucket,
          Key: key,
          Body: compressed,
          ContentType: 'image/webp',
        }),
      );

      const url = `https://${this.bucket}.s3.${this.region}.amazonaws.com/${key}`;
      urls.push(url);
    }

    return urls;
  }

  async deleteImage(imageUrl: string): Promise<void> {
    try {
      const url = new URL(imageUrl);
      const key = url.pathname.substring(1); // Remove leading /
      await this.s3.send(
        new DeleteObjectCommand({
          Bucket: this.bucket,
          Key: key,
        }),
      );
    } catch {
      // Silently fail on delete - image may not exist
    }
  }
}
