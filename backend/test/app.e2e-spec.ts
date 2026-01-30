import { Test, TestingModule } from '@nestjs/testing';
import { INestApplication, ValidationPipe } from '@nestjs/common';
import * as request from 'supertest';
import { AppModule } from '../src/app.module';
import { MikroOrmModule } from '@mikro-orm/nestjs';
import { CACHE_MANAGER } from '@nestjs/cache-manager';

describe('AppController (e2e)', () => {
  let app: INestApplication;

  const mockCacheManager = {
    get: jest.fn(),
    set: jest.fn(),
    del: jest.fn(),
  };

  beforeAll(async () => {
    const moduleFixture: TestingModule = await Test.createTestingModule({
      imports: [AppModule],
    })
      .overrideProvider(CACHE_MANAGER)
      .useValue(mockCacheManager)
      // Note: MikroORM is harder to override globally if imported via forRootAsync in AppModule
      // In a real project, we would use a test config or a separate test app module
      .compile();

    app = moduleFixture.createNestApplication();
    app.useGlobalPipes(new ValidationPipe());
    await app.init();
  });

  afterAll(async () => {
    await app.close();
  });

  it('/vehicles/search (GET)', async () => {
    mockCacheManager.get.mockResolvedValue(null);
    const response = await request(app.getHttpServer())
      .get('/vehicles/search')
      .query({ location: 'Colombo' })
      .expect(200);

    expect(response.body).toHaveProperty('items');
  });

  describe('Auth Protection', () => {
    it('should return 401 for protected booking route', async () => {
      await request(app.getHttpServer())
        .post('/bookings')
        .send({
          vehicleId: 'some-id',
          startDate: '2026-01-01',
          endDate: '2026-01-05',
        })
        .expect(401);
    });
  });
});
