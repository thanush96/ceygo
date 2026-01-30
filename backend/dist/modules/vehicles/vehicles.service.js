"use strict";
var __decorate = (this && this.__decorate) || function (decorators, target, key, desc) {
    var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
    if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
    else for (var i = decorators.length - 1; i >= 0; i--) if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
    return c > 3 && r && Object.defineProperty(target, key, r), r;
};
var __metadata = (this && this.__metadata) || function (k, v) {
    if (typeof Reflect === "object" && typeof Reflect.metadata === "function") return Reflect.metadata(k, v);
};
var __param = (this && this.__param) || function (paramIndex, decorator) {
    return function (target, key) { decorator(target, key, paramIndex); }
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.VehiclesService = void 0;
const common_1 = require("@nestjs/common");
const nestjs_1 = require("@mikro-orm/nestjs");
const postgresql_1 = require("@mikro-orm/postgresql");
const vehicle_entity_1 = require("./entities/vehicle.entity");
let VehiclesService = class VehiclesService {
    constructor(vehicleRepository) {
        this.vehicleRepository = vehicleRepository;
    }
    async create(createVehicleDto) {
        const vehicle = this.vehicleRepository.create(createVehicleDto);
        await this.vehicleRepository.getEntityManager().persistAndFlush(vehicle);
        return vehicle;
    }
    async findAll(brand) {
        if (brand) {
            return await this.vehicleRepository.find({ brand });
        }
        return await this.vehicleRepository.findAll();
    }
    async findOne(id) {
        const vehicle = await this.vehicleRepository.findOne({ id });
        if (!vehicle) {
            throw new common_1.NotFoundException(`Vehicle with ID ${id} not found`);
        }
        return vehicle;
    }
    async update(id, updateVehicleDto) {
        const vehicle = await this.findOne(id);
        Object.assign(vehicle, updateVehicleDto);
        await this.vehicleRepository.getEntityManager().flush();
        return vehicle;
    }
    async remove(id) {
        const vehicle = await this.findOne(id);
        await this.vehicleRepository.getEntityManager().removeAndFlush(vehicle);
    }
};
exports.VehiclesService = VehiclesService;
exports.VehiclesService = VehiclesService = __decorate([
    (0, common_1.Injectable)(),
    __param(0, (0, nestjs_1.InjectRepository)(vehicle_entity_1.Vehicle)),
    __metadata("design:paramtypes", [postgresql_1.EntityRepository])
], VehiclesService);
//# sourceMappingURL=vehicles.service.js.map