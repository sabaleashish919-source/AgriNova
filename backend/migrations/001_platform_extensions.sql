-- AgriNova platform extension schema (PostgreSQL-ready)
-- Existing MVP tables: users, products, orders, offers.
-- Apply these statements when migrating an existing production database.

CREATE TABLE IF NOT EXISTS markets (
  id SERIAL PRIMARY KEY,
  name VARCHAR(150) NOT NULL,
  location VARCHAR(150) NOT NULL,
  crop_name VARCHAR(100) NOT NULL,
  price_per_kg DOUBLE PRECISION NOT NULL,
  market_type VARCHAR(50) NOT NULL DEFAULT 'MANDI',
  observed_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);
CREATE INDEX IF NOT EXISTS ix_markets_crop_name ON markets(crop_name);
CREATE INDEX IF NOT EXISTS ix_markets_location ON markets(location);

CREATE TABLE IF NOT EXISTS buyer_demands (
  id SERIAL PRIMARY KEY,
  buyer_id INTEGER NOT NULL REFERENCES users(id),
  crop_name VARCHAR(100) NOT NULL,
  quantity_kg DOUBLE PRECISION NOT NULL,
  target_price_per_kg DOUBLE PRECISION,
  location VARCHAR(150) NOT NULL,
  status VARCHAR(30) NOT NULL DEFAULT 'OPEN',
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS fpos (
  id SERIAL PRIMARY KEY,
  owner_id INTEGER NOT NULL REFERENCES users(id),
  name VARCHAR(160) NOT NULL,
  registration_no VARCHAR(100),
  location VARCHAR(150) NOT NULL,
  member_count INTEGER NOT NULL DEFAULT 0,
  verified BOOLEAN NOT NULL DEFAULT FALSE
);

CREATE TABLE IF NOT EXISTS lots (
  id SERIAL PRIMARY KEY,
  fpo_id INTEGER NOT NULL REFERENCES fpos(id),
  crop_name VARCHAR(100) NOT NULL,
  quantity_kg DOUBLE PRECISION NOT NULL,
  quality_grade VARCHAR(30) NOT NULL DEFAULT 'A',
  asking_price_per_kg DOUBLE PRECISION NOT NULL,
  status VARCHAR(30) NOT NULL DEFAULT 'OPEN'
);

CREATE TABLE IF NOT EXISTS storage_facilities (
  id SERIAL PRIMARY KEY,
  provider_id INTEGER NOT NULL REFERENCES users(id),
  name VARCHAR(160) NOT NULL,
  location VARCHAR(150) NOT NULL,
  capacity_kg DOUBLE PRECISION NOT NULL,
  available_kg DOUBLE PRECISION NOT NULL,
  storage_type VARCHAR(60) NOT NULL DEFAULT 'GENERAL'
);

CREATE TABLE IF NOT EXISTS transport_options (
  id SERIAL PRIMARY KEY,
  provider_id INTEGER NOT NULL REFERENCES users(id),
  origin VARCHAR(150) NOT NULL,
  destination VARCHAR(150) NOT NULL,
  capacity_kg DOUBLE PRECISION NOT NULL,
  cost DOUBLE PRECISION NOT NULL,
  vehicle_type VARCHAR(60) NOT NULL,
  available BOOLEAN NOT NULL DEFAULT TRUE
);

CREATE TABLE IF NOT EXISTS grievances (
  id SERIAL PRIMARY KEY,
  user_id INTEGER NOT NULL REFERENCES users(id),
  subject VARCHAR(180) NOT NULL,
  description VARCHAR(1000) NOT NULL,
  status VARCHAR(30) NOT NULL DEFAULT 'OPEN',
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);
