import { Vehicle } from '../../src/modules/vehicles/entities/vehicle.entity';
import { User } from '../../src/modules/users/entities/user.entity';
import { v4 } from 'uuid';

export const createVehicleMock = (owner: User, overrides: Partial<Vehicle> = {}): Vehicle => {
  const vehicle = new Vehicle();
  Object.assign(vehicle, {
    id: v4(),
    name: 'Axio',
    brand: 'Toyota',
    pricePerDay: 5000,
    seats: 5,
    transmission: 'Auto',
    fuelType: 'Petrol',
    plateNo: 'WP CAB-1234',
    owner,
    status: 'available',
    verificationStatus: 'approved',
    isBlacklisted: false,
    rating: 4.5,
    tripCount: 10,
    location: 'Colombo',
    lat: 6.9271,
    lng: 79.8612,
    createdAt: new Date(),
    updatedAt: new Date(),
    ...overrides,
  });
  return vehicle;
};
