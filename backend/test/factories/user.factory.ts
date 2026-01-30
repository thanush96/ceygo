import { User } from '../../src/modules/users/entities/user.entity';
import { v4 } from 'uuid';

export const createUserMock = (overrides: Partial<User> = {}): User => {
  const user = new User();
  Object.assign(user, {
    id: v4(),
    name: 'Test User',
    email: `test-${v4()}@example.com`,
    phone: '+94771234567',
    nationality: 'Sri Lankan',
    idType: 'NIC',
    nic: '199412345678',
    licenseNo: 'B1234567',
    role: 'renter',
    verificationStatus: 'approved',
    status: 'active',
    createdAt: new Date(),
    updatedAt: new Date(),
    ...overrides,
  });
  return user;
};
