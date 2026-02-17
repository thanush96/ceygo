import { Migration } from '@mikro-orm/migrations';

export class Migration20260217232200 extends Migration {

  async up(): Promise<void> {
    this.addSql('set names \'utf8\';');

    this.addSql('create table "payments" ("id" uuid not null, "amount" numeric(10,2) not null, "status" varchar(255) not null default \'pending\', "gateway_ref" varchar(255) null, "method" varchar(255) not null, "created_at" timestamptz not null, "updated_at" timestamptz not null, constraint "payments_pkey" primary key ("id"));');

    this.addSql('create table "users" ("id" uuid not null, "name" varchar(255) not null, "email" varchar(255) not null, "phone" varchar(255) not null, "nationality" varchar(255) not null, "id_type" varchar(255) not null, "nic" varchar(255) not null, "license_no" varchar(255) not null, "profile_pic" varchar(255) null, "role" varchar(255) not null default \'renter\', "verification_status" varchar(255) not null default \'pending\', "status" varchar(255) not null default \'active\', "reason" varchar(255) null, "created_at" timestamptz not null, "updated_at" timestamptz not null, constraint "users_pkey" primary key ("id"));');
    this.addSql('alter table "users" add constraint "users_email_unique" unique ("email");');
    this.addSql('alter table "users" add constraint "users_phone_unique" unique ("phone");');
    this.addSql('alter table "users" add constraint "users_nic_unique" unique ("nic");');

    this.addSql('create table "chat_messages" ("id" uuid not null, "sender_id" uuid not null, "receiver_id" uuid not null, "message" text not null, "is_read" boolean not null default false, "timestamp" timestamptz not null, constraint "chat_messages_pkey" primary key ("id"));');

    this.addSql('create table "vehicles" ("id" uuid not null, "name" varchar(255) not null, "brand" varchar(255) not null, "brand_logo" varchar(255) null, "image_url" varchar(255) null, "price_per_day" numeric(10,2) not null, "seats" int not null, "transmission" varchar(255) not null, "fuel_type" varchar(255) not null, "rating" numeric(2,1) not null default 0, "trip_count" int not null default 0, "owner_id" uuid not null, "plate_no" varchar(255) not null, "airport_pickup_available" boolean not null default false, "status" varchar(255) not null default \'available\', "verification_status" varchar(255) not null default \'pending\', "is_blacklisted" boolean not null default false, "reason" varchar(255) null, "location" text null, "lat" numeric(10,8) null, "lng" numeric(11,8) null, "deleted_at" timestamptz null, "created_at" timestamptz not null, "updated_at" timestamptz not null, constraint "vehicles_pkey" primary key ("id"));');
    this.addSql('create index "vehicles_price_per_day_index" on "vehicles" ("price_per_day");');
    this.addSql('create index "vehicles_rating_index" on "vehicles" ("rating");');
    this.addSql('alter table "vehicles" add constraint "vehicles_plate_no_unique" unique ("plate_no");');
    this.addSql('create index "vehicles_status_index" on "vehicles" ("status");');
    this.addSql('create index "vehicles_lat_index" on "vehicles" ("lat");');
    this.addSql('create index "vehicles_lng_index" on "vehicles" ("lng");');
    this.addSql('create index "vehicles_lat_lng_index" on "vehicles" ("lat", "lng");');
    this.addSql('create index "vehicles_owner_id_index" on "vehicles" ("owner_id");');
    this.addSql('create index "vehicles_status_price_per_day_index" on "vehicles" ("status", "price_per_day");');

    this.addSql('create table "bookings" ("id" uuid not null, "renter_id" uuid not null, "vehicle_id" uuid not null, "start_date" timestamptz not null, "end_date" timestamptz not null, "pickup_location" text not null, "dropoff_location" text not null, "flight_number" varchar(255) null, "total_price" numeric(10,2) not null, "currency" varchar(255) not null default \'LKR\', "status" varchar(255) not null default \'pending\', "payment_id" uuid null, "created_at" timestamptz not null, "updated_at" timestamptz not null, constraint "bookings_pkey" primary key ("id"));');
    this.addSql('create index "bookings_start_date_index" on "bookings" ("start_date");');
    this.addSql('create index "bookings_end_date_index" on "bookings" ("end_date");');
    this.addSql('alter table "bookings" add constraint "bookings_payment_id_unique" unique ("payment_id");');
    this.addSql('create index "bookings_vehicle_id_start_date_end_date_index" on "bookings" ("vehicle_id", "start_date", "end_date");');
    this.addSql('create index "bookings_renter_id_index" on "bookings" ("renter_id");');

    this.addSql('alter table "chat_messages" add constraint "chat_messages_sender_id_foreign" foreign key ("sender_id") references "users" ("id") on update cascade;');
    this.addSql('alter table "chat_messages" add constraint "chat_messages_receiver_id_foreign" foreign key ("receiver_id") references "users" ("id") on update cascade;');

    this.addSql('alter table "vehicles" add constraint "vehicles_owner_id_foreign" foreign key ("owner_id") references "users" ("id") on update cascade;');

    this.addSql('alter table "bookings" add constraint "bookings_renter_id_foreign" foreign key ("renter_id") references "users" ("id") on update cascade;');
    this.addSql('alter table "bookings" add constraint "bookings_vehicle_id_foreign" foreign key ("vehicle_id") references "vehicles" ("id") on update cascade;');
    this.addSql('alter table "bookings" add constraint "bookings_payment_id_foreign" foreign key ("payment_id") references "payments" ("id") on update cascade on delete set null;');
  }

  async down(): Promise<void> {
    this.addSql('alter table "chat_messages" drop constraint "chat_messages_sender_id_foreign";');
    this.addSql('alter table "chat_messages" drop constraint "chat_messages_receiver_id_foreign";');

    this.addSql('alter table "vehicles" drop constraint "vehicles_owner_id_foreign";');

    this.addSql('alter table "bookings" drop constraint "bookings_renter_id_foreign";');
    this.addSql('alter table "bookings" drop constraint "bookings_vehicle_id_foreign";');
    this.addSql('alter table "bookings" drop constraint "bookings_payment_id_foreign";');

    this.addSql('drop table if exists "payments" cascade;');
    this.addSql('drop table if exists "users" cascade;');
    this.addSql('drop table if exists "chat_messages" cascade;');
    this.addSql('drop table if exists "vehicles" cascade;');
    this.addSql('drop table if exists "bookings" cascade;');
  }

}
