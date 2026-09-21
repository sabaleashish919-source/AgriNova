# AgriNova Architecture

## Runtime flow

Flutter UI → Dio REST client → FastAPI → SQLAlchemy → SQLite (MVP) / PostgreSQL (production)

The backend remains authoritative for stock, orders, surplus calculation, export routing, and role access.

## Marketplace intelligence

For each crop:

`Surplus % = max(Supply - Domestic Demand, 0) / Domestic Demand`

The default configurable activation threshold is 20%. When a crop crosses the threshold, active listings for that crop become export-only and are removed from the domestic consumer marketplace. International buyers can then see eligible listings.

## Platform modules

- Farmer supply and crop listings
- Domestic consumer marketplace and orders
- International surplus marketplace
- Mandi / market observations and price comparison
- Processor, bulk and institutional buyer demand
- FPO registration and collective lot creation
- Quality grading and quality-linked listing data
- Transport capacity and route-cost comparison
- Storage capacity discovery
- Grievances and support tracking
- Government monitoring and aggregate policy analytics
- Admin operations

## Production path

1. Move from SQLite to PostgreSQL using `AGRINOVA_DB_URL`.
2. Run `backend/migrations/001_platform_extensions.sql` for the platform extension tables.
3. Put `AGRINOVA_SECRET_KEY` in a managed secret store.
4. Serve FastAPI behind HTTPS and a production reverse proxy.
5. Add object storage for crop/document images.
6. Add real payment, notification, KYC and export-compliance providers as external integrations.
7. Add historical data pipelines before ML demand/price forecasting.
