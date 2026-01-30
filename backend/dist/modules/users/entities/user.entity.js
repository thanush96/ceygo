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
exports.User = void 0;
const core_1 = require("@mikro-orm/core");
const class_validator_1 = require("class-validator");
const uuid_1 = require("uuid");
const booking_entity_1 = require("../../bookings/entities/booking.entity");
let User = class User {
    constructor() {
        this.id = (0, uuid_1.v4)();
        this.role = 'renter';
        this.bookings = new core_1.Collection(this);
        this.createdAt = new Date();
        this.updatedAt = new Date();
    }
};
exports.User = User;
__decorate([
    (0, core_1.PrimaryKey)({ type: 'uuid' }),
    __metadata("design:type", String)
], User.prototype, "id", void 0);
__decorate([
    (0, core_1.Property)(),
    (0, class_validator_1.IsString)(),
    (0, class_validator_1.IsNotEmpty)(),
    __metadata("design:type", String)
], User.prototype, "name", void 0);
__decorate([
    (0, core_1.Property)({ unique: true }),
    (0, class_validator_1.IsEmail)(),
    __metadata("design:type", String)
], User.prototype, "email", void 0);
__decorate([
    (0, core_1.Property)({ unique: true }),
    (0, class_validator_1.IsString)(),
    (0, class_validator_1.IsNotEmpty)(),
    (0, class_validator_1.Matches)(/^(?:\+94|0)7[0-9]{8}$/, {
        message: 'Mobile number must be a valid Sri Lankan format (e.g., +94771234567 or 0771234567)',
    }),
    __metadata("design:type", String)
], User.prototype, "phone", void 0);
__decorate([
    (0, core_1.Property)({ unique: true }),
    (0, class_validator_1.IsString)(),
    (0, class_validator_1.IsNotEmpty)(),
    (0, class_validator_1.Matches)(/^(?:[0-9]{9}[xXvV]|[0-9]{12})$/, {
        message: 'NIC must be a valid Sri Lankan format (e.g., 941234567V or 199412345678)',
    }),
    __metadata("design:type", String)
], User.prototype, "nic", void 0);
__decorate([
    (0, core_1.Property)(),
    (0, class_validator_1.IsEnum)(['renter', 'owner', 'admin']),
    __metadata("design:type", String)
], User.prototype, "role", void 0);
__decorate([
    (0, core_1.OneToMany)(() => booking_entity_1.Booking, (booking) => booking.user),
    __metadata("design:type", Object)
], User.prototype, "bookings", void 0);
__decorate([
    (0, core_1.Property)({ onCreate: () => new Date() }),
    __metadata("design:type", Date)
], User.prototype, "createdAt", void 0);
__decorate([
    (0, core_1.Property)({ onUpdate: () => new Date() }),
    __metadata("design:type", Date)
], User.prototype, "updatedAt", void 0);
exports.User = User = __decorate([
    (0, core_1.Entity)({ tableName: 'users' })
], User);
//# sourceMappingURL=user.entity.js.map