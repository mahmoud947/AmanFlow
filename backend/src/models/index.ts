import { Schema, model } from 'mongoose';

const opts = { versionKey: false, timestamps: true } as const;

export const Customer = model(
  'Customer',
  new Schema(
    {
      customerId: { type: String, required: true, unique: true },
      identifier: { type: String, required: true, unique: true },
      passwordHash: { type: String, required: true, select: false },
      code: { type: String, required: true, unique: true },
      name: { type: String, required: true },
      phone: { type: String, required: true },
    },
    opts,
  ),
);

export const Wallet = model(
  'Wallet',
  new Schema(
    {
      customerId: { type: String, required: true },
      balance: { type: Number, required: true },
      currency: { type: String, required: true, default: 'EGP' },
      maskedNumber: { type: String, required: true },
    },
    opts,
  ),
);

export const Transaction = model(
  'Transaction',
  new Schema(
    {
      customerId: { type: String, required: true },
      title: { type: String, required: true },
      category: { type: String, required: true },
      direction: { type: String, enum: ['debit', 'credit'], required: true },
      amount: { type: Number, required: true },
      occurredAt: { type: Date, required: true },
    },
    opts,
  ),
);

export const PaymentService = model(
  'PaymentService',
  new Schema(
    {
      key: { type: String, required: true, unique: true },
      name: { type: String, required: true },
      category: { type: String, required: true },
      description: { type: String, required: true },
    },
    opts,
  ),
);

export const Payment = model(
  'Payment',
  new Schema(
    {
      customerId: { type: String, required: true },
      serviceKey: { type: String, required: true },
      serviceName: { type: String, required: true },
      amount: { type: Number, required: true },
      reference: { type: String, required: true },
      status: { type: String, enum: ['completed'], default: 'completed' },
    },
    opts,
  ),
);
