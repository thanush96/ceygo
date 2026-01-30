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
Object.defineProperty(exports, "__esModule", { value: true });
exports.Vehicle = void 0;
const core_1 = require("@mikro-orm/core");
const class_validator_1 = require("class-validator");
const uuid_1 = require("uuid");
const booking_entity_1 = require("../../bookings/entities/booking.entity");
let Vehicle = class Vehicle {
    constructor() {
        this.id = (0, uuid_1.v4)();
        this.status = 'available';
        this.bookings = new core_1.Collection(this);
        this.createdAt = new Date();
        this.updatedAt = new Date();
    }
};
exports.Vehicle = Vehicle;
__decorate([
    (0, core_1.PrimaryKey)({ type: 'uuid' }),
    __metadata("design:type", String)
], Vehicle.prototype, "id", void 0);
__decorate([
    (0, core_1.Property)(),
    (0, class_validator_1.IsString)(),
    (0, class_validator_1.IsNotEmpty)(),
    __metadata("design:type", String)
], Vehicle.prototype, "name", void 0);
__decorate([
    (0, core_1.Property)(),
    (0, class_validator_1.IsString)(),
    (0, class_validator_1.IsNotEmpty)(),
    __metadata("design:type", String)
], Vehicle.prototype, "brand", void 0);
__decorate([
    (0, core_1.Property)({ type: 'decimal', precision: 10, scale: 2 }),
    (0, class_validator_1.IsNumber)(),
    __metadata("design:type", Number)
], Vehicle.prototype, "pricePerDay", void 0);
__decorate([
    (0, core_1.Property)(),
    (0, class_validator_1.IsNumber)(),
    __metadata("design:type", Number)
], Vehicle.prototype, "seats", void 0);
__decorate([
    (0, core_1.Property)(),
    (0, class_validator_1.IsEnum)(['Manual', 'Auto']),
    __metadata("design:type", String)
], Vehicle.prototype, "transmission", void 0);
__decorate([
    (0, core_1.Property)(),
    (0, class_validator_1.IsEnum)(['Petrol', 'Diesel', 'Electric', 'Hybrid']),
    __metadata("design:type", String)
], Vehicle.prototype, "fuelType", void 0);
__decorate([
    (0, core_1.Property)({ unique: true }),
    (0, class_validator_1.IsString)(),
    (0, class_validator_1.IsNotEmpty)(),
    __metadata("design:type", String)
], Vehicle.prototype, "plateNo", void 0);
__decorate([
    (0, core_1.Property)(),
    (0, class_validator_1.IsEnum)(['available', 'booked', 'maintenance']),
    __metadata("design:type", String)
], Vehicle.prototype, "status", void 0);
__decorate([
    (0, core_1.OneToMany)(() => booking_entity_1.Booking, (booking) => booking.vehicle),
    __metadata("design:type", Object)
], Vehicle.prototype, "bookings", void 0);
__decorate([
    (0, core_1.Property)({ onCreate: () => new Date() }),
    __metadata("design:type", Date)
], Vehicle.prototype, "createdAt", void 0);
__decorate([
    (0, core_1.Property)({ onUpdate: () => new Date() }),
    __metadata("design:type", Date)
], Vehicle.prototype, "updatedAt", void 0);
exports.Vehicle = Vehicle = __decorate([
    (0, core_1.Entity)({ tableName: 'vehicles' })
], Vehicle);
//# sourceMappingURL=vehicle.entity.js.map