# API

Base URL: `http://localhost:4000`. No authentication is required in the baseline.

| Method | Path | Description |
|---|---|---|
| GET | `/health` | `{ "status": "ok" }` |
| GET | `/wallet` | `{ id, customerId, balance, currency, maskedNumber }` |
| GET | `/transactions` | Transactions, newest first: `{ id, title, category, direction: "debit"\|"credit", amount, occurredAt }` |
| GET | `/services` | Payment services: `{ id, name, category, description }` |
| GET | `/profile` | `{ id, name, phone, customerCode }` |
| GET | `/payments` | Last 10 payments |
| POST | `/payments` | Make a payment |

## POST /payments
Request:
```json
{ "serviceId": "recharge", "amount": 150, "reference": "01012345678" }
```
- `serviceId` must match a service `id` from `/services` (`recharge`, `electricity`, `internet`, `water`, `gas`, `donations`).
- `amount` must be a number > 0. `reference` must be a non-empty string.

Responses:
- `201` `{ id, serviceId, serviceName, amount, reference, status: "completed", createdAt }`. Also adds a debit transaction and reduces the wallet balance.
- `400` `{ error: "validation_error", details: [{ field, message }] }`
- `404` `{ error: "service_not_found" }`
