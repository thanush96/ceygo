import type { EntityManager } from '@mikro-orm/core';
import { Seeder } from '@mikro-orm/seeder';
import { User } from '@modules/users/entities/user.entity';
import { Vehicle } from '@modules/vehicles/entities/vehicle.entity';

export class DatabaseSeeder extends Seeder {
  async run(em: EntityManager): Promise<void> {
    // Check if data already exists
    const existingUsers = await em.count(User, {});
    if (existingUsers > 0) {
      console.log('Database already has data, skipping seed.');
      return;
    }

    // --- Owner Profiles ---
    const owner1 = em.create(User, {
      name: 'Kamal Perera',
      email: 'kamal@ceygo.lk',
      phone: '+94771234567',
      nationality: 'Sri Lankan',
      idType: 'NIC',
      nic: '199012345678',
      licenseNo: 'B1234567',
      role: 'owner',
      verificationStatus: 'approved',
      status: 'active',
    });

    const owner2 = em.create(User, {
      name: 'Nimal Fernando',
      email: 'nimal@ceygo.lk',
      phone: '+94772345678',
      nationality: 'Sri Lankan',
      idType: 'NIC',
      nic: '198823456789',
      licenseNo: 'B2345678',
      role: 'owner',
      verificationStatus: 'approved',
      status: 'active',
    });

    const owner3 = em.create(User, {
      name: 'Suresh Kumar',
      email: 'suresh@ceygo.lk',
      phone: '+94773456789',
      nationality: 'Sri Lankan',
      idType: 'NIC',
      nic: '199534567890',
      licenseNo: 'B3456789',
      role: 'owner',
      verificationStatus: 'approved',
      status: 'active',
    });

    // --- Brand Logo URLs ---
    const logos: Record<string, string> = {
      Toyota: 'https://raw.githubusercontent.com/filippofilip95/car-logos-dataset/master/logos/thumb/toyota.png',
      BMW: 'https://raw.githubusercontent.com/filippofilip95/car-logos-dataset/master/logos/thumb/bmw.png',
      'Mercedes-Benz': 'https://raw.githubusercontent.com/filippofilip95/car-logos-dataset/master/logos/thumb/mercedes-benz.png',
      Hyundai: 'https://raw.githubusercontent.com/filippofilip95/car-logos-dataset/master/logos/thumb/hyundai.png',
      Jeep: 'https://raw.githubusercontent.com/filippofilip95/car-logos-dataset/master/logos/thumb/jeep.png',
      Honda: 'https://raw.githubusercontent.com/filippofilip95/car-logos-dataset/master/logos/thumb/honda.png',
      Nissan: 'https://raw.githubusercontent.com/filippofilip95/car-logos-dataset/master/logos/thumb/nissan.png',
      Suzuki: 'https://raw.githubusercontent.com/filippofilip95/car-logos-dataset/master/logos/thumb/suzuki.png',
    };

    // Sample car images (free stock photos)
    const carImages = {
      corolla: 'https://images.unsplash.com/photo-1621007947382-bb3c3994e3fb?w=800',
      coaster: 'https://images.unsplash.com/photo-1570125909232-eb263c188f7e?w=800',
      kdh: 'https://images.unsplash.com/photo-1609520505218-7421df70f42a?w=800',
      bmw3: 'https://images.unsplash.com/photo-1555215695-3004980ad54e?w=800',
      bmw5: 'https://images.unsplash.com/photo-1523983388277-336a66bf9bcd?w=800',
      bmwx5: 'https://images.unsplash.com/photo-1606611013016-969c19ba27e5?w=800',
      benz: 'https://images.unsplash.com/photo-1618843479313-40f8afb4b4d8?w=800',
      tucson: 'https://images.unsplash.com/photo-1633695635793-248f5640b4f5?w=800',
      wrangler: 'https://images.unsplash.com/photo-1519641471654-76ce0107ad1b?w=800',
      civic: 'https://images.unsplash.com/photo-1590362891991-f776e747a588?w=800',
      xtrail: 'https://images.unsplash.com/photo-1609521263047-f8f205293f24?w=800',
      swift: 'https://images.unsplash.com/photo-1549317661-bd32c8ce0afe?w=800',
    };

    // --- Vehicles (owned by the 3 owners) ---

    // Owner 1: Kamal's vehicles
    em.create(Vehicle, {
      name: 'Corolla',
      brand: 'Toyota',
      brandLogo: logos.Toyota,
      imageUrl: carImages.corolla,
      pricePerDay: 8000,
      seats: 5,
      transmission: 'Auto',
      fuelType: 'Hybrid',
      rating: 4.5,
      tripCount: 120,
      owner: owner1,
      plateNo: 'CAB-1234',
      airportPickupAvailable: true,
      status: 'available',
      verificationStatus: 'approved',
      location: 'Colombo',
      lat: 6.9271,
      lng: 79.8612,
    });

    em.create(Vehicle, {
      name: 'Coaster',
      brand: 'Toyota',
      brandLogo: logos.Toyota,
      imageUrl: carImages.coaster,
      pricePerDay: 25000,
      seats: 29,
      transmission: 'Manual',
      fuelType: 'Diesel',
      rating: 4.7,
      tripCount: 45,
      owner: owner1,
      plateNo: 'NW-5678',
      airportPickupAvailable: false,
      status: 'available',
      verificationStatus: 'approved',
      location: 'Kandy',
      lat: 7.2906,
      lng: 80.6337,
    });

    em.create(Vehicle, {
      name: 'KDH Van',
      brand: 'Toyota',
      brandLogo: logos.Toyota,
      imageUrl: carImages.kdh,
      pricePerDay: 15000,
      seats: 15,
      transmission: 'Auto',
      fuelType: 'Diesel',
      rating: 4.6,
      tripCount: 89,
      owner: owner1,
      plateNo: 'WP-9012',
      airportPickupAvailable: true,
      status: 'available',
      verificationStatus: 'approved',
      location: 'Colombo',
      lat: 6.9344,
      lng: 79.8428,
    });

    em.create(Vehicle, {
      name: 'Civic',
      brand: 'Honda',
      brandLogo: logos.Honda,
      imageUrl: carImages.civic,
      pricePerDay: 9000,
      seats: 5,
      transmission: 'Auto',
      fuelType: 'Petrol',
      rating: 4.4,
      tripCount: 95,
      owner: owner1,
      plateNo: 'CAB-4321',
      airportPickupAvailable: true,
      status: 'available',
      verificationStatus: 'approved',
      location: 'Colombo',
      lat: 6.9185,
      lng: 79.8477,
    });

    // Owner 2: Nimal's vehicles
    em.create(Vehicle, {
      name: '3 Series',
      brand: 'BMW',
      brandLogo: logos.BMW,
      imageUrl: carImages.bmw3,
      pricePerDay: 18000,
      seats: 5,
      transmission: 'Auto',
      fuelType: 'Petrol',
      rating: 4.8,
      tripCount: 67,
      owner: owner2,
      plateNo: 'WP-3456',
      airportPickupAvailable: true,
      status: 'available',
      verificationStatus: 'approved',
      location: 'Colombo',
      lat: 6.9147,
      lng: 79.8727,
    });

    em.create(Vehicle, {
      name: '5 Series',
      brand: 'BMW',
      brandLogo: logos.BMW,
      imageUrl: carImages.bmw5,
      pricePerDay: 22000,
      seats: 5,
      transmission: 'Auto',
      fuelType: 'Petrol',
      rating: 4.9,
      tripCount: 34,
      owner: owner2,
      plateNo: 'WP-7890',
      airportPickupAvailable: true,
      status: 'available',
      verificationStatus: 'approved',
      location: 'Colombo',
      lat: 6.9220,
      lng: 79.8530,
    });

    em.create(Vehicle, {
      name: 'X5',
      brand: 'BMW',
      brandLogo: logos.BMW,
      imageUrl: carImages.bmwx5,
      pricePerDay: 28000,
      seats: 7,
      transmission: 'Auto',
      fuelType: 'Diesel',
      rating: 4.8,
      tripCount: 28,
      owner: owner2,
      plateNo: 'SP-2345',
      airportPickupAvailable: true,
      status: 'available',
      verificationStatus: 'approved',
      location: 'Galle',
      lat: 6.0535,
      lng: 80.2210,
    });

    em.create(Vehicle, {
      name: 'E-Class',
      brand: 'Mercedes-Benz',
      brandLogo: logos['Mercedes-Benz'],
      imageUrl: carImages.benz,
      pricePerDay: 25000,
      seats: 5,
      transmission: 'Auto',
      fuelType: 'Petrol',
      rating: 4.9,
      tripCount: 52,
      owner: owner2,
      plateNo: 'WP-6789',
      airportPickupAvailable: true,
      status: 'available',
      verificationStatus: 'approved',
      location: 'Colombo',
      lat: 6.9271,
      lng: 79.8612,
    });

    // Owner 3: Suresh's vehicles
    em.create(Vehicle, {
      name: 'Tucson',
      brand: 'Hyundai',
      brandLogo: logos.Hyundai,
      imageUrl: carImages.tucson,
      pricePerDay: 12000,
      seats: 5,
      transmission: 'Auto',
      fuelType: 'Diesel',
      rating: 4.5,
      tripCount: 156,
      owner: owner3,
      plateNo: 'EP-1234',
      airportPickupAvailable: false,
      status: 'available',
      verificationStatus: 'approved',
      location: 'Kandy',
      lat: 7.2906,
      lng: 80.6337,
    });

    em.create(Vehicle, {
      name: 'Wrangler',
      brand: 'Jeep',
      brandLogo: logos.Jeep,
      imageUrl: carImages.wrangler,
      pricePerDay: 20000,
      seats: 5,
      transmission: 'Auto',
      fuelType: 'Petrol',
      rating: 4.7,
      tripCount: 73,
      owner: owner3,
      plateNo: 'SG-5678',
      airportPickupAvailable: true,
      status: 'available',
      verificationStatus: 'approved',
      location: 'Colombo',
      lat: 6.9350,
      lng: 79.8538,
    });

    em.create(Vehicle, {
      name: 'X-Trail',
      brand: 'Nissan',
      brandLogo: logos.Nissan,
      imageUrl: carImages.xtrail,
      pricePerDay: 11000,
      seats: 5,
      transmission: 'Auto',
      fuelType: 'Petrol',
      rating: 4.3,
      tripCount: 42,
      owner: owner3,
      plateNo: 'NW-3456',
      airportPickupAvailable: false,
      status: 'available',
      verificationStatus: 'approved',
      location: 'Negombo',
      lat: 7.2008,
      lng: 79.8737,
    });

    em.create(Vehicle, {
      name: 'Swift',
      brand: 'Suzuki',
      brandLogo: logos.Suzuki,
      imageUrl: carImages.swift,
      pricePerDay: 6000,
      seats: 5,
      transmission: 'Auto',
      fuelType: 'Petrol',
      rating: 4.2,
      tripCount: 210,
      owner: owner3,
      plateNo: 'WP-8901',
      airportPickupAvailable: false,
      status: 'available',
      verificationStatus: 'approved',
      location: 'Colombo',
      lat: 6.9271,
      lng: 79.8612,
    });

    await em.flush();
    console.log('Seed complete: 3 owners + 12 vehicles created.');
  }
}
