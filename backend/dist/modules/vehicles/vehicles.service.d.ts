import { EntityRepository } from '@mikro-orm/postgresql';
import { Vehicle } from './entities/vehicle.entity';
import { CreateVehicleDto } from './dto/create-vehicle.dto';
export declare class VehiclesService {
    private readonly vehicleRepository;
    constructor(vehicleRepository: EntityRepository<Vehicle>);
    create(createVehicleDto: CreateVehicleDto): Promise<Vehicle>;
    findAll(brand?: string): Promise<Vehicle[]>;
    findOne(id: string): Promise<Vehicle>;
    update(id: string, updateVehicleDto: Partial<CreateVehicleDto>): Promise<Vehicle>;
    remove(id: string): Promise<void>;
}
