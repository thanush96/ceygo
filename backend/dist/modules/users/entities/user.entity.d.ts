import { Collection } from '@mikro-orm/core';
import { Booking } from '@modules/bookings/entities/booking.entity';
export declare class User {
    id: string;
    name: string;
    email: string;
    phone: string;
    nic: string;
    role: string;
    bookings: Collection<Booking, object>;
    createdAt: Date;
    updatedAt: Date;
}
