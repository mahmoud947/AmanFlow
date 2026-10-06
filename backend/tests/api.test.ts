import request from 'supertest';
import { beforeEach, describe, expect, it, vi } from 'vitest';

const { wallet, service } = vi.hoisted(() => ({
  wallet: { findOne: vi.fn() },
  service: { findOne: vi.fn() },
}));

vi.mock('../src/models', () => ({
  Wallet: { findOne: () => ({ lean: wallet.findOne }), updateOne: vi.fn() },
  PaymentService: { findOne: () => ({ lean: service.findOne }) },
  Customer: {},
  Transaction: { create: vi.fn() },
  Payment: { create: vi.fn().mockResolvedValue({ _id: 'pay_1' }) },
}));

import { createApp } from '../src/app';

const app = createApp();

describe('API sanity', () => {
  beforeEach(() => vi.clearAllMocks());

  it('GET /health', async () => {
    const res = await request(app).get('/health');
    expect(res.status).toBe(200);
    expect(res.body).toEqual({ status: 'ok' });
  });

  it('GET /wallet', async () => {
    wallet.findOne.mockResolvedValue({ customerId: 'customer_001', balance: 12450, currency: 'EGP', maskedNumber: '•••• 4821' });
    const res = await request(app).get('/wallet');
    expect(res.status).toBe(200);
    expect(res.body).toMatchObject({ id: 'wallet_001', balance: 12450, currency: 'EGP' });
  });

  it('POST /payments rejects missing fields and bad amounts', async () => {
    expect((await request(app).post('/payments').send({})).status).toBe(400);
    const bad = await request(app).post('/payments').send({ serviceId: 'recharge', amount: 0, reference: '0100' });
    expect(bad.status).toBe(400);
  });

  it('POST /payments rejects unknown service', async () => {
    service.findOne.mockResolvedValue(null);
    const res = await request(app).post('/payments').send({ serviceId: 'nope', amount: 10, reference: 'x' });
    expect(res.status).toBe(404);
  });

  it('POST /payments succeeds for a valid request', async () => {
    service.findOne.mockResolvedValue({ key: 'recharge', name: 'Mobile Recharge' });
    const res = await request(app).post('/payments').send({ serviceId: 'recharge', amount: 50, reference: '01012345678' });
    expect(res.status).toBe(201);
    expect(res.body.status).toBe('completed');
  });
});
