import { VehiclesService } from './vehicles.service';
import { CreateVehicleDto } from './dto/create-vehicle.dto';
export declare class VehiclesController {
    private readonly vehiclesService;
    constructor(vehiclesService: VehiclesService);
    create(createVehicleDto: CreateVehicleDto): Promise<import("./entities/vehicle.entity").Vehicle>;
    findAll(brand?: string): Promise<import("./entities/vehicle.entity").Vehicle[]>;
    findOne(id: string): Promise<import("./entities/vehicle.entity").Vehicle>;
    update(id: string, updateVehicleDto: Partial<CreateVehicleDto>): Promise<import("./entities/vehicle.entity").Vehicle>;
    remove(id: string): Promise<void>;
}
