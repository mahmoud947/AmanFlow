# Current State (baseline)

AmanFlow is a small fictional fintech demo: a Flutter mobile app backed by a Node/Express API and MongoDB.

## What exists
- **Mobile** (`mobile/`): Home (balance card, quick actions, recent transactions), Payments (service grid, payment sheet, recent payments), Profile (customer card and settings rows).
- **Backend** (`backend/`): `GET /health`, `/wallet`, `/transactions`, `/services`, `/profile`, `GET|POST /payments`.
- **Data**: one deterministic fictional customer (Ahmed Hassan, `AF-102938`), seeded via `npm run seed`.
- **Payment mutation**: the payment sheet calls `POST /payments`, which records the payment and a transaction and debits the wallet.

## What does not exist
- No login or register screens, credentials, password hashes, tokens, or session handling.
- No auth middleware: every endpoint is open, and the API assumes a single hard-coded customer (`customer_001`).
- No biometrics, no secure local storage.
- The Profile > Security row is a placeholder that shows "Security settings" and does nothing.

Authentication and authorization are intentionally outside the baseline implementation and represent the next planned product capability.

## Other known limitations
- "Send Money", "View All" and notifications are placeholders.
- Payments are simulated; no real payment provider is involved.
- Only one customer exists, so there is no multi-user data separation.
