import { Options, PostgreSqlDriver } from '@mikro-orm/postgresql';
import { Migrator } from '@mikro-orm/migrations';
import { SeedManager } from '@mikro-orm/seeder';
import * as dotenv from 'dotenv';

dotenv.config();

const config: Options = {
  driver: PostgreSqlDriver,
  host: process.env.DB_HOST,
  port: parseInt(process.env.DB_PORT || '5432', 10),
  user: process.env.DB_USERNAME || process.env.DB_USER,
  password: process.env.DB_PASSWORD,
  dbName: process.env.DB_DATABASE || process.env.DB_NAME,
  entities: ['dist/**/*.entity.js'],
  entitiesTs: ['src/**/*.entity.ts'],
  driverOptions: {
    connection: {
      ssl: process.env.DB_SSL === 'true' ? { rejectUnauthorized: false } : false,
    },
  },
  migrations: {
    path: 'dist/database/migrations',
    pathTs: 'src/database/migrations',
  },
  seeder: {
    path: 'dist/seeders',
    pathTs: 'src/seeders',
  },
  extensions: [Migrator, SeedManager],
};

export default config;
