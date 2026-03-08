import { Migration } from '@mikro-orm/migrations';

export class Migration20260308121000 extends Migration {

  async up(): Promise<void> {
    this.addSql('create table "vehicle_brands" ("id" uuid not null, "name" varchar(255) not null, "logo_url" varchar(255) not null, "is_active" boolean not null default true, "created_at" timestamptz not null, "updated_at" timestamptz not null, constraint "vehicle_brands_pkey" primary key ("id"));');
    this.addSql('alter table "vehicle_brands" add constraint "vehicle_brands_name_unique" unique ("name");');
    this.addSql('create index "vehicle_brands_name_index" on "vehicle_brands" ("name");');

    this.addSql(`
      insert into "vehicle_brands" ("id", "name", "logo_url", "is_active", "created_at", "updated_at") values
      ('6c9d3a40-90d5-4d5b-8cb7-7dc932c23a01', 'Toyota', 'https://raw.githubusercontent.com/filippofilip95/car-logos-dataset/master/logos/thumb/toyota.png', true, now(), now()),
      ('6c9d3a40-90d5-4d5b-8cb7-7dc932c23a02', 'BMW', 'https://raw.githubusercontent.com/filippofilip95/car-logos-dataset/master/logos/thumb/bmw.png', true, now(), now()),
      ('6c9d3a40-90d5-4d5b-8cb7-7dc932c23a03', 'Mercedes-Benz', 'https://raw.githubusercontent.com/filippofilip95/car-logos-dataset/master/logos/thumb/mercedes-benz.png', true, now(), now()),
      ('6c9d3a40-90d5-4d5b-8cb7-7dc932c23a04', 'Hyundai', 'https://raw.githubusercontent.com/filippofilip95/car-logos-dataset/master/logos/thumb/hyundai.png', true, now(), now()),
      ('6c9d3a40-90d5-4d5b-8cb7-7dc932c23a05', 'Jeep', 'https://raw.githubusercontent.com/filippofilip95/car-logos-dataset/master/logos/thumb/jeep.png', true, now(), now()),
      ('6c9d3a40-90d5-4d5b-8cb7-7dc932c23a06', 'Honda', 'https://raw.githubusercontent.com/filippofilip95/car-logos-dataset/master/logos/thumb/honda.png', true, now(), now()),
      ('6c9d3a40-90d5-4d5b-8cb7-7dc932c23a07', 'Nissan', 'https://raw.githubusercontent.com/filippofilip95/car-logos-dataset/master/logos/thumb/nissan.png', true, now(), now()),
      ('6c9d3a40-90d5-4d5b-8cb7-7dc932c23a08', 'Suzuki', 'https://raw.githubusercontent.com/filippofilip95/car-logos-dataset/master/logos/thumb/suzuki.png', true, now(), now()),
      ('6c9d3a40-90d5-4d5b-8cb7-7dc932c23a09', 'Audi', 'https://raw.githubusercontent.com/filippofilip95/car-logos-dataset/master/logos/thumb/audi.png', true, now(), now()),
      ('6c9d3a40-90d5-4d5b-8cb7-7dc932c23a0a', 'Kia', 'https://raw.githubusercontent.com/filippofilip95/car-logos-dataset/master/logos/thumb/kia.png', true, now(), now()),
      ('6c9d3a40-90d5-4d5b-8cb7-7dc932c23a0b', 'Mazda', 'https://raw.githubusercontent.com/filippofilip95/car-logos-dataset/master/logos/thumb/mazda.png', true, now(), now()),
      ('6c9d3a40-90d5-4d5b-8cb7-7dc932c23a0c', 'Mitsubishi', 'https://raw.githubusercontent.com/filippofilip95/car-logos-dataset/master/logos/thumb/mitsubishi.png', true, now(), now())
      on conflict ("name") do update set
      "logo_url" = excluded."logo_url",
      "is_active" = true,
      "updated_at" = now();
    `);

    this.addSql(`
      update "vehicles" v
      set "brand_logo" = b."logo_url"
      from "vehicle_brands" b
      where lower(v."brand") = lower(b."name")
      and (v."brand_logo" is null or v."brand_logo" = '');
    `);
  }

  async down(): Promise<void> {
    this.addSql('drop table if exists "vehicle_brands" cascade;');
  }

}
