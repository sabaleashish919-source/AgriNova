# AgriNova

Smart agricultural surplus marketplace MVP.

## Flutter

```powershell
flutter pub get
flutter analyze
flutter run -d chrome
```

The app expects the API at `http://localhost:8000/api/v1` by default.

## Backend

```powershell
cd backend
python -m venv .venv
.venv\Scripts\activate
pip install -r requirements.txt
uvicorn main:app --reload --port 8000
```

Then start Flutter in another terminal.

## Current working flows

- Registration for Farmer, Consumer and International Buyer
- Login and JWT session storage
- Farmer: add/list/delete crops
- Consumer: marketplace and orders endpoint
- International buyer: export marketplace
- Surplus monitor with 20% activation threshold
- Admin market monitor

This is an MVP foundation, not a claim of production certification. Production hardening still includes PostgreSQL, secret management, HTTPS, payments, notifications, export compliance, monitoring and automated tests.
