# Architecture

```
Flutter (mobile/)
   ↓  HTTP/JSON
REST API
   ↓
Node + Express + TypeScript (backend/)
   ↓  Mongoose
MongoDB (docker compose)
```

## Boundary
The mobile app only knows the REST contract in [api.md](api.md) and a configurable base URL. The backend owns all data and business rules (payment validation, wallet debit).

## Mobile (`mobile/lib`)
| Folder | Role |
|---|---|
| `core/` | `config.dart` (API base URL), `theme.dart` (colors, spacing, formatters) |
| `data/` | `api_client.dart` (HTTP), `models.dart`, `repository.dart` (`FinanceRepository` interface + `ApiFinanceRepository`) |
| `state/` | `app_state.dart`: one `ChangeNotifier` provided with `provider` |
| `widgets/` | Reusable components: AppHeader, BalanceCard, QuickAction, TransactionItem, ServiceCard, SectionHeader, PrimaryButton, AppBottomNavigation |
| `screens/` | `shell.dart` (bottom nav), Home, Payments, Profile, payment sheet |

Flow: screen → `AppState` → `FinanceRepository` → `ApiClient` → backend.

## Backend (`backend/src`)
| File | Role |
|---|---|
| `server.ts` | connects to MongoDB and starts Express |
| `app.ts` | Express app factory (used by tests) |
| `routes/index.ts` | all routes and request validation (zod) |
| `models/index.ts` | Mongoose models: Customer, Wallet, Transaction, PaymentService, Payment |
| `data.ts`, `seed.ts` | deterministic seed data and seed script |
| `config/env.ts` | `PORT`, `MONGODB_URI` |

## Configuration
- Backend: `backend/.env` (copy from `.env.example`). Default port is **4000**.
- Mobile: `--dart-define=API_BASE_URL=...`. Defaults to `http://10.0.2.2:4000` on Android emulator and `http://localhost:4000` elsewhere.
