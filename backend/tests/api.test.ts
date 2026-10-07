import request from 'supertest';
import { beforeEach, describe, expect, it, vi } from 'vitest';

const { account, wallet, transactions, profile, service, payment } = vi.hoisted(() => ({
  account: { findOne: vi.fn() },
  wallet: { findOne: vi.fn(), updateOne: vi.fn() },
  transactions: { find: vi.fn(), create: vi.fn() },
  profile: { findOne: vi.fn() },
  service: { findOne: vi.fn() },
  payment: { create: vi.fn(), find: vi.fn() },
}));

vi.mock('../src/models', () => ({
  Account: { findOne: () => ({ lean: account.findOne }) },
  Wallet: { findOne: (filter: unknown) => ({ lean: () => wallet.findOne(filter) }), updateOne: wallet.updateOne },
  PaymentService: { findOne: () => ({ lean: service.findOne }), find: vi.fn() },
  Customer: { findOne: (filter: unknown) => ({ lean: () => profile.findOne(filter) }) },
  Transaction: { find: (filter: unknown) => ({ sort: () => ({ lean: () => transactions.find(filter) }) }), create: transactions.create },
  Payment: { create: payment.create, find: (filter: unknown) => ({ sort: () => ({ limit: () => ({ lean: () => payment.find(filter) }) }) }) },
}));

import { hashPassword } from '../src/auth';
import { createApp } from '../src/app';

const app = createApp();

async function signIn(customerId: string) {
  account.findOne.mockResolvedValue({ customerId, passwordHash: hashPassword('test-password') });
  const response = await request(app).post('/auth/login').send({ identifier: 'user@example.test', password: 'test-password' });
  expect(response.status).toBe(200);
  return `Bearer ${response.body.token as string}`;
}

describe('authenticated API', () => {
  beforeEach(() => vi.resetAllMocks());

  it('keeps health public and denies financial routes without a valid session', async () => {
    expect((await request(app).get('/health')).body).toEqual({ status: 'ok' });
    for (const path of ['/wallet', '/transactions', '/payments', '/profile', '/services']) {
      expect((await request(app).get(path)).status).toBe(401);
    }
    expect((await request(app).post('/payments').send({})).status).toBe(401);
    expect(wallet.findOne).not.toHaveBeenCalled();
  });

  it('rejects missing and incorrect credentials without a session', async () => {
    expect((await request(app).post('/auth/login').send({})).status).toBe(400);
    account.findOne.mockResolvedValue({ customerId: 'one', passwordHash: hashPassword('correct') });
    expect((await request(app).post('/auth/login').send({ identifier: 'user@example.test', password: 'wrong' })).status).toBe(401);
    expect((await request(app).get('/wallet').set('Authorization', 'Bearer invalid')).status).toBe(401);
  });

  it('scopes wallet, transactions, profile and payments to the authenticated identity', async () => {
    const authorization = await signIn('second_customer');
    wallet.findOne.mockResolvedValue(null);
    transactions.find.mockResolvedValue([]);
    profile.findOne.mockResolvedValue(null);
    payment.find.mockResolvedValue([]);
    await request(app).get('/wallet?customerId=customer_001').set('Authorization', authorization);
    await request(app).get('/transactions').set('Authorization', authorization);
    await request(app).get('/profile').set('Authorization', authorization);
    await request(app).get('/payments').set('Authorization', authorization);
    for (const mock of [wallet.findOne, transactions.find, profile.findOne, payment.find]) {
      expect(mock).toHaveBeenCalledWith({ customerId: 'second_customer' });
    }
  });

  it('scopes payment writes to the authenticated identity', async () => {
    const authorization = await signIn('second_customer');
    service.findOne.mockResolvedValue({ key: 'recharge', name: 'Mobile Recharge' });
    payment.create.mockResolvedValue({ _id: 'p1' });
    const response = await request(app).post('/payments').set('Authorization', authorization)
      .send({ serviceId: 'recharge', amount: 50, reference: '01012345678', customerId: 'customer_001' });
    expect(response.status).toBe(201);
    expect(payment.create).toHaveBeenCalledWith(expect.objectContaining({ customerId: 'second_customer' }));
    expect(transactions.create).toHaveBeenCalledWith(expect.objectContaining({ customerId: 'second_customer' }));
    expect(wallet.updateOne).toHaveBeenCalledWith({ customerId: 'second_customer' }, { $inc: { balance: -50 } });
  });
});
