import mongoose from 'mongoose';
import { createApp } from './app';
import { env } from './config/env';

async function main() {
  await mongoose.connect(env.mongoUri);
  createApp().listen(env.port, () => console.log(`AmanFlow API listening on :${env.port}`));
}

main().catch((e) => {
  console.error(e);
  process.exit(1);
});
