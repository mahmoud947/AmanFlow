// Deterministic demo data. Entirely fictional.
export const CUSTOMER_ID = 'customer_001';
// Fictional demo-only account; never use these example credentials for a real account.
export const DEMO_IDENTIFIER = 'demo@amanflow.example';
export const DEMO_PASSWORD = 'Demo-only-2026!';

export const seedCustomer = {
  customerId: CUSTOMER_ID,
  identifier: DEMO_IDENTIFIER,
  code: 'AF-102938',
  name: 'Ahmed Hassan',
  phone: '+20 10 *** **67',
};

export const seedWallet = {
  customerId: CUSTOMER_ID,
  balance: 12450,
  currency: 'EGP',
  maskedNumber: '•••• 4821',
};

export const seedServices = [
  { key: 'recharge', name: 'Mobile Recharge', category: 'telecom', description: 'Top up any mobile line' },
  { key: 'electricity', name: 'Electricity', category: 'utilities', description: 'Pay your electricity bill' },
  { key: 'internet', name: 'Internet', category: 'telecom', description: 'Home internet and DSL' },
  { key: 'water', name: 'Water', category: 'utilities', description: 'Pay your water bill' },
  { key: 'gas', name: 'Gas', category: 'utilities', description: 'Natural gas bills' },
  { key: 'donations', name: 'Donations', category: 'giving', description: 'Support a registered charity' },
];

const d = (iso: string) => new Date(iso);
export const seedTransactions = [
  { customerId: CUSTOMER_ID, title: 'Vodafone Recharge', category: 'recharge', direction: 'debit', amount: 150, occurredAt: d('2026-10-05T18:30:00Z') },
  { customerId: CUSTOMER_ID, title: 'Electricity Bill', category: 'electricity', direction: 'debit', amount: 620, occurredAt: d('2026-10-04T10:15:00Z') },
  { customerId: CUSTOMER_ID, title: 'Money Transfer', category: 'transfer', direction: 'debit', amount: 1250, occurredAt: d('2026-10-03T14:00:00Z') },
  { customerId: CUSTOMER_ID, title: 'Cashback', category: 'cashback', direction: 'credit', amount: 75, occurredAt: d('2026-10-02T09:00:00Z') },
  { customerId: CUSTOMER_ID, title: 'Internet Bill', category: 'internet', direction: 'debit', amount: 399, occurredAt: d('2026-10-01T12:00:00Z') },
] as const;
