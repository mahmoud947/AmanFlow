# AmanFlow (demo)

A small, fictional fintech app used as a baseline product: Flutter mobile + Node/TypeScript API + MongoDB.
All data is fictional. See [docs/current-state.md](docs/current-state.md), [docs/architecture.md](docs/architecture.md) and [docs/api.md](docs/api.md).

```
amanflow-demo/
├── mobile/    Flutter app (Home, Payments, Profile)
├── backend/   Express + Mongoose API
├── docs/
├── docker-compose.yml   local MongoDB
└── .env.example
```

## Prerequisites
Node 20+, Flutter 3.x, Docker. For Android builds use JDK 17 or 21 (JDK 25 is rejected by the bundled Gradle).

## 1. Start MongoDB
```bash
docker compose up -d
```

## 2. Backend (port 4000)
```bash
cd backend
cp .env.example .env
npm install
npm run seed      # deterministic demo data (safe to re-run; resets the data)
npm run dev       # http://localhost:4000/health
```
Other scripts: `npm run build`, `npm test` (tests mock the database and need no MongoDB).

## 3. Mobile
```bash
cd mobile
flutter pub get
flutter analyze
flutter test
flutter run                                              # iOS simulator: uses http://localhost:4000
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:4000   # Android emulator
```
The Android emulator reaches the host machine at `http://10.0.2.2:<port>`. For a physical device, use your machine's LAN IP.

## Try it
Home shows the wallet and transactions from the API. On Payments, tap a service, enter a number and amount, and press **Pay now** to `POST /payments`. The balance and transactions refresh.

## Scope
This is the pre-authentication baseline. There is intentionally no login, token, or biometric layer yet.
