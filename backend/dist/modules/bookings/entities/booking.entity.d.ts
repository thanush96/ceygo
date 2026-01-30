import { Rel } from '@mikro-orm/core';
import { User } from '@modules/users/entities/user.entity';
import { Vehicle } from '@modules/vehicles/entities/vehicle.entity';
export declare class Booking {
    id: string;
    user: Rel<User>;
    vehicle: Rel<Vehicle>;
    startDate: Date;
    endDate: Date;
    totalPrice: number;
    status: string;
    createdAt: Date;
    updatedAt: Date;
}
