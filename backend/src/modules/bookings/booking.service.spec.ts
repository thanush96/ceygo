import { Test, TestingModule } from '@nestjs/testing';
import { BookingService } from './booking.service';
import { getRepositoryToken } from '@mikro-orm/nestjs';
import { Booking } from './entities/booking.entity';
import { Vehicle } from '@modules/vehicles/entities/vehicle.entity';
import { User } from '@modules/users/entities/user.entity';
import { Payment } from '@modules/payments/entities/payment.entity';
import { EntityManager } from '@mikro-orm/postgresql';
import { PayHereService } from '@modules/payments/payhere.service';
import { ConflictException, NotFoundException } from '@nestjs/common';
import { createUserMock } from '../../../test/factories/user.factory';
import { createVehicleMock } from '../../../test/factories/vehicle.factory';
import { createBookingMock } from '../../../test/factories/booking.factory';

describe('BookingService', () => {
  let service: BookingService;
  let em: any;

  const mockBookingRepo = {
    findOne: jest.fn(),
    find: jest.fn(),
    create: jest.fn(),
  };

  const mockVehicleRepo = {
    findOne: jest.fn(),
  };

  const mockUserRepo = {
    findOne: jest.fn(),
  };

  const mockPaymentRepo = {
    create: jest.fn(),
  };

  const mockPayHereService = {
    generatePaymentLink: jest.fn().mockReturnValue('http://mocklink.com'),
    refundPayment: jest.fn(),
  };

  beforeEach(async () => {
    em = {
      transactional: jest.fn().mockImplementation((cb) => cb(em)),
      findOne: jest.fn(),
      create: jest.fn().mockImplementation((entity, data) => data),
      persistAndFlush: jest.fn(),
      flush: jest.fn(),
    };

    const module: TestingModule = await Test.createTestingModule({
      providers: [
        BookingService,
        { provide: EntityManager, useValue: em },
        { provide: getRepositoryToken(Booking), useValue: mockBookingRepo },
        { provide: getRepositoryToken(Vehicle), useValue: mockVehicleRepo },
        { provide: getRepositoryToken(User), useValue: mockUserRepo },
        { provide: getRepositoryToken(Payment), useValue: mockPaymentRepo },
        { provide: PayHereService, useValue: mockPayHereService },
      ],
    }).compile();

    service = module.get<BookingService>(BookingService);
  });

  it('should be defined', () => {
    expect(service).toBeDefined();
  });

  describe('createBooking', () => {
    it('should throw ConflictException if start date is after end date', async () => {
      const renter = createUserMock();
      const dto = {
        vehicleId: 'v1',
        startDate: '2026-05-10',
        endDate: '2026-05-09',
        pickupLocation: 'Loc',
        dropoffLocation: 'Loc',
      };
      await expect(service.createBooking(renter.id, dto)).rejects.toThrow(ConflictException);
    });

    it('should create a booking and return payment link', async () => {
      const renter = createUserMock();
      const vehicle = createVehicleMock(createUserMock());
      const dto = {
        vehicleId: vehicle.id,
        startDate: '2026-06-01',
        endDate: '2026-06-05',
        pickupLocation: 'Airport',
        dropoffLocation: 'City',
      };

      em.findOne.mockImplementation((entity, criteria) => {
        if (entity === Vehicle) return vehicle;
        if (entity === User) return renter;
        if (entity === Booking) return null; // No overlapping
        return null;
      });

      const result = await service.createBooking(renter.id, dto);
      expect(result).toHaveProperty('paymentLink');
      expect(em.transactional).toHaveBeenCalled();
      expect(em.persistAndFlush).toHaveBeenCalled();
    });

    it('should throw ConflictException if vehicle is already booked', async () => {
      const renter = createUserMock();
      const vehicle = createVehicleMock(createUserMock());
      const existingBooking = createBookingMock(renter, vehicle);
      const dto = {
        vehicleId: vehicle.id,
        startDate: '2026-06-01',
        endDate: '2026-06-05',
        pickupLocation: 'Airport',
        dropoffLocation: 'City',
      };

      em.findOne.mockImplementation((entity, criteria) => {
        if (entity === Vehicle) return vehicle;
        if (entity === User) return renter;
        if (entity === Booking) return existingBooking; // Overlap
        return null;
      });

      await expect(service.createBooking(renter.id, dto)).rejects.toThrow(ConflictException);
    });
  });

  describe('calculatePrice', () => {
    it('should calculate correct total price based on days', async () => {
      const renter = createUserMock();
      const vehicle = createVehicleMock(createUserMock(), { pricePerDay: 4000 });
      const dto = {
        vehicleId: vehicle.id,
        startDate: '2026-07-01',
        endDate: '2026-07-04', // 3 days
        pickupLocation: 'X',
        dropoffLocation: 'Y',
      };

      em.findOne.mockImplementation((entity) => {
        if (entity === Vehicle) return vehicle;
        if (entity === User) return renter;
        return null;
      });

      const result: any = await service.createBooking(renter.id, dto);
      expect(result.booking.totalPrice).toBe(12000);
    });
  });
});
