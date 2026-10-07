import request from 'supertest';
import { beforeEach, describe, expect, it, vi } from 'vitest';

const mocks = vi.hoisted(() => ({
  customer: vi.fn(),
  wallet: vi.fn(),
  walletUpdate: vi.fn(),
  service: vi.fn(),
  paymentCreate: vi.fn(),
  transactionCreate: vi.fn(),
}));

vi.mock('../src/models', () => ({
  Customer: { findOne: (query: unknown) => ({
    select: () => ({ lean: () => mocks.customer(query) }),
    lean: () => mocks.customer(query),
  }) },
  Wallet: { findOne: (query: unknown) => ({ lean: () => mocks.wallet(query) }), updateOne: mocks.walletUpdate },
  PaymentService: { findOne: () => ({ lean: mocks.service }) },
  Transaction: { create: mocks.transactionCreate },
  Payment: { create: mocks.paymentCreate },
}));

import { createApp } from '../src/app';
import { hashPassword, verifyPassword } from '../src/auth';
import { CUSTOMER_ID, DEMO_IDENTIFIER, DEMO_PASSWORD, seedCustomer } from '../src/data';

const app = createApp();

async function signIn(identifier = DEMO_IDENTIFIER, password = DEMO_PASSWORD) {
  return request(app).post('/auth/login').send({ identifier, password });
}

describe('authenticated demo API', () => {
  beforeEach(async () => {
    vi.clearAllMocks();
    mocks.customer.mockResolvedValue({ ...seedCustomer, passwordHash: await hashPassword(DEMO_PASSWORD) });
    mocks.wallet.mockResolvedValue({ _id: 'w1', customerId: CUSTOMER_ID, balance: 12450, currency: 'EGP', maskedNumber: '•••• 4821' });
    mocks.service.mockResolvedValue({ key: 'recharge', name: 'Mobile Recharge' });
    mocks.paymentCreate.mockResolvedValue({ _id: 'pay_1' });
  });

  it('keeps health public and requires a session for financial routes', async () => {
    expect((await request(app).get('/health')).body).toEqual({ status: 'ok' });
    for (const path of ['/wallet', '/transactions', '/payments', '/profile', '/services']) {
      expect((await request(app).get(path)).status).toBe(401);
    }
    expect((await request(app).post('/payments').send({})).status).toBe(401);
    expect((await request(app).get('/wallet').set('Authorization', 'Bearer invalid')).status).toBe(401);
  });

  it('authenticates the fictional seed account, without returning its hash', async () => {
    const hash = await hashPassword(DEMO_PASSWORD);
    expect(await verifyPassword(DEMO_PASSWORD, hash)).toBe(true);
    expect(await verifyPassword('wrong', hash)).toBe(false);
    const login = await signIn();
    expect(login.status).toBe(200);
    expect(login.body).toEqual({ token: expect.any(String) });
    expect(JSON.stringify(login.body)).not.toContain('passwordHash');
    expect(mocks.customer).toHaveBeenCalledWith({ identifier: DEMO_IDENTIFIER });
    const wallet = await request(app).get('/wallet').set('Authorization', `Bearer ${login.body.token}`);
    expect(wallet.status).toBe(200);
    expect(wallet.body).toMatchObject({ customerId: CUSTOMER_ID, balance: 12450 });
    expect(mocks.wallet).toHaveBeenCalledWith({ customerId: CUSTOMER_ID });
  });

  it('rejects missing and incorrect credentials without creating a session', async () => {
    expect((await signIn('', '')).status).toBe(400);
    const bad = await signIn(DEMO_IDENTIFIER, 'incorrect');
    expect(bad.status).toBe(401);
    expect(bad.body).toEqual({ error: 'invalid_credentials' });
    mocks.customer.mockResolvedValue(null);
    expect((await signIn('unknown@example.com', 'incorrect')).body).toEqual(bad.body);
  });

  it('scopes profile and payment writes to the session identity', async () => {
    const login = await signIn();
    const auth = `Bearer ${login.body.token}`;
    const profile = await request(app).get('/profile').set('Authorization', auth);
    expect(profile.status).toBe(200);
    expect(profile.body.id).toBe(CUSTOMER_ID);
    expect(mocks.customer).toHaveBeenCalledWith({ customerId: CUSTOMER_ID });
    expect((await request(app).post('/payments').set('Authorization', auth).send({})).status).toBe(400);
    const payment = await request(app).post('/payments').set('Authorization', auth)
      .send({ serviceId: 'recharge', amount: 50, reference: '01012345678', customerId: 'other' });
    expect(payment.status).toBe(201);
    expect(mocks.paymentCreate).toHaveBeenCalledWith(expect.objectContaining({ customerId: CUSTOMER_ID }));
    expect(mocks.transactionCreate).toHaveBeenCalledWith(expect.objectContaining({ customerId: CUSTOMER_ID }));
    expect(mocks.walletUpdate).toHaveBeenCalledWith({ customerId: CUSTOMER_ID }, expect.anything());
  });
});
