import mongoose from 'mongoose';
import { hashPassword } from './auth';
import { env } from './config/env';
import { DEMO_IDENTIFIER, DEMO_PASSWORD, seedCustomer, seedServices, seedTransactions, seedWallet } from './data';
import { Customer, Payment, PaymentService, Transaction, Wallet } from './models';

async function main() {
  await mongoose.connect(env.mongoUri);
  await Customer.deleteMany({});
  await Wallet.deleteMany({});
  await Transaction.deleteMany({});
  await PaymentService.deleteMany({});
  await Payment.deleteMany({});
  await Customer.create({ ...seedCustomer, passwordHash: await hashPassword(DEMO_PASSWORD) });
  await Wallet.create(seedWallet);
  await PaymentService.insertMany(seedServices);
  await Transaction.insertMany(seedTransactions);
  console.log(`Seed complete. Fictional demo sign-in: ${DEMO_IDENTIFIER} / ${DEMO_PASSWORD}`);
  await mongoose.disconnect();
}

main().catch((e) => {
  console.error(e);
  process.exit(1);
});
