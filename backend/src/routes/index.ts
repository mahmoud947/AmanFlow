import { Router } from 'express';
import { z } from 'zod';
import { CUSTOMER_ID } from '../data';
import { Customer, Payment, PaymentService, Transaction, Wallet } from '../models';

export const router = Router();

const paymentSchema = z.object({
  serviceId: z.string().min(1),
  amount: z.number().positive(),
  reference: z.string().min(1),
});

router.get('/health', (_req, res) => {
  res.json({ status: 'ok' });
});

router.get('/wallet', async (_req, res, next) => {
  try {
    const w = await Wallet.findOne({ customerId: CUSTOMER_ID }).lean();
    if (!w) return res.status(404).json({ error: 'wallet_not_found' });
    res.json({
      id: 'wallet_001',
      customerId: w.customerId,
      balance: w.balance,
      currency: w.currency,
      maskedNumber: w.maskedNumber,
    });
  } catch (e) {
    next(e);
  }
});

router.get('/transactions', async (_req, res, next) => {
  try {
    const list = await Transaction.find({ customerId: CUSTOMER_ID }).sort({ occurredAt: -1 }).lean();
    res.json(
      list.map((t) => ({
        id: String(t._id),
        title: t.title,
        category: t.category,
        direction: t.direction,
        amount: t.amount,
        occurredAt: t.occurredAt.toISOString(),
      })),
    );
  } catch (e) {
    next(e);
  }
});

router.get('/services', async (_req, res, next) => {
  try {
    const list = await PaymentService.find().sort({ _id: 1 }).lean();
    res.json(
      list.map((s) => ({
        id: s.key,
        name: s.name,
        category: s.category,
        description: s.description,
      })),
    );
  } catch (e) {
    next(e);
  }
});

router.post('/payments', async (req, res, next) => {
  try {
    const parsed = paymentSchema.safeParse(req.body);
    if (!parsed.success) {
      return res.status(400).json({
        error: 'validation_error',
        details: parsed.error.issues.map((i) => ({ field: i.path.join('.'), message: i.message })),
      });
    }
    const { serviceId, amount, reference } = parsed.data;
    const service = await PaymentService.findOne({ key: serviceId }).lean();
    if (!service) return res.status(404).json({ error: 'service_not_found' });

    const payment = await Payment.create({
      customerId: CUSTOMER_ID,
      serviceKey: service.key,
      serviceName: service.name,
      amount,
      reference,
    });
    await Transaction.create({
      customerId: CUSTOMER_ID,
      title: service.name,
      category: service.key,
      direction: 'debit',
      amount,
      occurredAt: new Date(),
    });
    await Wallet.updateOne({ customerId: CUSTOMER_ID }, { $inc: { balance: -amount } });

    res.status(201).json({
      id: String(payment._id),
      serviceId: service.key,
      serviceName: service.name,
      amount,
      reference,
      status: 'completed',
      createdAt: new Date().toISOString(),
    });
  } catch (e) {
    next(e);
  }
});

router.get('/payments', async (_req, res, next) => {
  try {
    const list = await Payment.find({ customerId: CUSTOMER_ID }).sort({ createdAt: -1 }).limit(10).lean();
    res.json(
      list.map((p) => ({
        id: String(p._id),
        serviceId: p.serviceKey,
        serviceName: p.serviceName,
        amount: p.amount,
        reference: p.reference,
        status: p.status,
        createdAt: (p as unknown as { createdAt: Date }).createdAt.toISOString(),
      })),
    );
  } catch (e) {
    next(e);
  }
});

router.get('/profile', async (_req, res, next) => {
  try {
    const c = await Customer.findOne().lean();
    if (!c) return res.status(404).json({ error: 'customer_not_found' });
    res.json({ id: CUSTOMER_ID, name: c.name, phone: c.phone, customerCode: c.code });
  } catch (e) {
    next(e);
  }
});
