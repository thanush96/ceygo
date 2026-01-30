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
exports.Booking = void 0;
const core_1 = require("@mikro-orm/core");
const class_validator_1 = require("class-validator");
const uuid_1 = require("uuid");
const user_entity_1 = require("../../users/entities/user.entity");
const vehicle_entity_1 = require("../../vehicles/entities/vehicle.entity");
let Booking = class Booking {
    constructor() {
        this.id = (0, uuid_1.v4)();
        this.status = 'pending';
        this.createdAt = new Date();
        this.updatedAt = new Date();
    }
};
exports.Booking = Booking;
__decorate([
    (0, core_1.PrimaryKey)({ type: 'uuid' }),
    __metadata("design:type", String)
], Booking.prototype, "id", void 0);
__decorate([
    (0, core_1.ManyToOne)(() => user_entity_1.User),
    __metadata("design:type", Object)
], Booking.prototype, "user", void 0);
__decorate([
    (0, core_1.ManyToOne)(() => vehicle_entity_1.Vehicle),
    __metadata("design:type", Object)
], Booking.prototype, "vehicle", void 0);
__decorate([
    (0, core_1.Property)(),
    (0, class_validator_1.IsDate)(),
    __metadata("design:type", Date)
], Booking.prototype, "startDate", void 0);
__decorate([
    (0, core_1.Property)(),
    (0, class_validator_1.IsDate)(),
    __metadata("design:type", Date)
], Booking.prototype, "endDate", void 0);
__decorate([
    (0, core_1.Property)({ type: 'decimal', precision: 10, scale: 2 }),
    (0, class_validator_1.IsNumber)(),
    __metadata("design:type", Number)
], Booking.prototype, "totalPrice", void 0);
__decorate([
    (0, core_1.Property)(),
    (0, class_validator_1.IsEnum)(['pending', 'confirmed', 'completed', 'cancelled']),
    __metadata("design:type", String)
], Booking.prototype, "status", void 0);
__decorate([
    (0, core_1.Property)({ onCreate: () => new Date() }),
    __metadata("design:type", Date)
], Booking.prototype, "createdAt", void 0);
__decorate([
    (0, core_1.Property)({ onUpdate: () => new Date() }),
    __metadata("design:type", Date)
], Booking.prototype, "updatedAt", void 0);
exports.Booking = Booking = __decorate([
    (0, core_1.Entity)({ tableName: 'bookings' })
], Booking);
//# sourceMappingURL=booking.entity.js.map