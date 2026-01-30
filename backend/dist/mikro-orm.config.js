"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const postgresql_1 = require("@mikro-orm/postgresql");
const postgresql_2 = require("@mikro-orm/postgresql");
const dotenv = require("dotenv");
dotenv.config();
exports.default = (0, postgresql_1.defineConfig)({
    driver: postgresql_2.PostgreSqlDriver,
    host: process.env.DB_HOST,
    port: parseInt(process.env.DB_PORT || '5432'),
    user: process.env.DB_USERNAME,
    password: process.env.DB_PASSWORD,
    dbName: process.env.DB_DATABASE,
    entities: ['dist/**/*.entity.js'],
    entitiesTs: ['src/**/*.entity.ts'],
    debug: process.env.NODE_ENV === 'development',
    driverOptions: {
        connection: {
            ssl: process.env.DB_SSL === 'true' ? { rejectUnauthorized: false } : false,
        },
    },
    migrations: {
        path: 'src/migrations',
        pathTs: 'src/migrations',
    },
});
//# sourceMappingURL=mikro-orm.config.js.map