import { Collection } from '@mikro-orm/core';
import { Booking } from '@modules/bookings/entities/booking.entity';
export declare class Vehicle {
    id: string;
    name: string;
    brand: string;
    pricePerDay: number;
    seats: number;
    transmission: string;
    fuelType: string;
    plateNo: string;
    status: string;
    bookings: Collection<Booking, object>;
    createdAt: Date;
    updatedAt: Date;
}
