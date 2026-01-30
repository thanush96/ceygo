import { Booking } from '../../src/modules/bookings/entities/booking.entity';
import { Vehicle } from '../../src/modules/vehicles/entities/vehicle.entity';
import { User } from '../../src/modules/users/entities/user.entity';
import { Payment } from '../../src/modules/payments/entities/payment.entity';
import { v4 } from 'uuid';

export const createBookingMock = (renter: User, vehicle: Vehicle, overrides: Partial<Booking> = {}): Booking => {
  const booking = new Booking();
  const start = new Date();
  start.setDate(start.getDate() + 1);
  const end = new Date();
  end.setDate(end.getDate() + 3);

  Object.assign(booking, {
    id: v4(),
    renter,
    vehicle,
    startDate: start,
    endDate: end,
    pickupLocation: 'Colombo Airport',
    dropoffLocation: 'Colombo City',
    totalPrice: 15000,
    currency: 'LKR',
    status: 'pending',
    createdAt: new Date(),
    updatedAt: new Date(),
    ...overrides,
  });

  const payment = new Payment();
  Object.assign(payment, {
    id: v4(),
    booking,
    amount: 15000,
    status: 'pending',
    method: 'PayHere',
    createdAt: new Date(),
  });
  booking.payment = payment;

  return booking;
};
