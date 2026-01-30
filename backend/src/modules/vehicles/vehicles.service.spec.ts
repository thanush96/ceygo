import { Test, TestingModule } from '@nestjs/testing';
import { VehiclesService } from './vehicles.service';
import { getRepositoryToken } from '@mikro-orm/nestjs';
import { Vehicle } from './entities/vehicle.entity';
import { Booking } from '@modules/bookings/entities/booking.entity';
import { EntityManager } from '@mikro-orm/postgresql';
import { CACHE_MANAGER } from '@nestjs/cache-manager';
import { createUserMock } from '../../../test/factories/user.factory';
import { createVehicleMock } from '../../../test/factories/vehicle.factory';

describe('VehiclesService', () => {
  let service: VehiclesService;
  let cacheManager: any;

  const mockVehicleRepo = {
    findAndCount: jest.fn(),
    findOne: jest.fn(),
    create: jest.fn().mockImplementation((data) => data),
    persistAndFlush: jest.fn(),
    createQueryBuilder: jest.fn(),
  };

  const mockBookingRepo = {
    find: jest.fn(),
    findOne: jest.fn(),
  };

  const mockCacheManager = {
    get: jest.fn(),
    set: jest.fn(),
    del: jest.fn(),
  };

  const mockEm = {
    persistAndFlush: jest.fn(),
    flush: jest.fn(),
    createQueryBuilder: jest.fn(),
  };

  beforeEach(async () => {
    jest.clearAllMocks();
    const module: TestingModule = await Test.createTestingModule({
      providers: [
        VehiclesService,
        { provide: getRepositoryToken(Vehicle), useValue: mockVehicleRepo },
        { provide: getRepositoryToken(Booking), useValue: mockBookingRepo },
        { provide: EntityManager, useValue: mockEm },
        { provide: CACHE_MANAGER, useValue: mockCacheManager },
      ],
    }).compile();

    service = module.get<VehiclesService>(VehiclesService);
    cacheManager = module.get(CACHE_MANAGER);
  });

  it('should be defined', () => {
    expect(service).toBeDefined();
  });

  describe('checkAvailability', () => {
    it('should return true if no overlapping bookings found', async () => {
      mockCacheManager.get.mockResolvedValue(undefined);
      mockBookingRepo.findOne.mockResolvedValue(null);

      const result = await service.checkAvailability('v1', '2026-01-01', '2026-01-05');
      expect(result).toBe(true);
      expect(mockBookingRepo.findOne).toHaveBeenCalled();
    });

    it('should return false if overlapping booking exists', async () => {
      mockCacheManager.get.mockResolvedValue(undefined);
      mockBookingRepo.findOne.mockResolvedValue({ id: 'b1' });

      const result = await service.checkAvailability('v1', '2026-01-01', '2026-01-05');
      expect(result).toBe(false);
    });

    it('should return cached value if available', async () => {
      mockCacheManager.get.mockResolvedValue(true);
      const result = await service.checkAvailability('v1', '2026-01-01', '2026-01-05');
      expect(result).toBe(true);
      expect(mockBookingRepo.findOne).not.toHaveBeenCalled();
    });
  });

  describe('getVehicleById', () => {
    it('should return cached vehicle if exists', async () => {
      const vehicle = createVehicleMock(createUserMock());
      mockCacheManager.get.mockResolvedValue(vehicle);

      const result = await service.getVehicleById(vehicle.id);
      expect(result).toEqual(vehicle);
      expect(mockVehicleRepo.findOne).not.toHaveBeenCalled();
    });
  });

  describe('searchVehicles', () => {
    it('should call createQueryBuilder and return items', async () => {
      const vehicle = createVehicleMock(createUserMock());
      const mockQb = {
        select: jest.fn().mockReturnThis(),
        where: jest.fn().mockReturnThis(),
        andWhere: jest.fn().mockReturnThis(),
        orderBy: jest.fn().mockReturnThis(),
        limit: jest.fn().mockReturnThis(),
        offset: jest.fn().mockReturnThis(),
        getResultAndCount: jest.fn().mockResolvedValue([[vehicle], 1]),
      };
      mockVehicleRepo.createQueryBuilder.mockReturnValue(mockQb);
      mockCacheManager.get.mockResolvedValue(null);

      const result: any = await service.searchVehicles({ location: 'Colombo' } as any);
      expect(result.items).toHaveLength(1);
      expect(mockVehicleRepo.createQueryBuilder).toHaveBeenCalled();
    });
  });
});
