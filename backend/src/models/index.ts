import { Schema, model } from 'mongoose';

const opts = { versionKey: false, timestamps: true } as const;

// Accounts must be provisioned with a customerId matching the financial records.
// Passwords are stored only as salted scrypt hashes (see auth.ts).
export const Account = model(
  'Account',
  new Schema(
    {
      identifier: { type: String, required: true, unique: true },
      passwordHash: { type: String, required: true },
      customerId: { type: String, required: true },
    },
    opts,
  ),
);

export const Customer = model(
  'Customer',
  new Schema(
    {
      customerId: { type: String, required: true, unique: true },
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
