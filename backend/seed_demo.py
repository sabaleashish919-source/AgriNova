"""Optional local demo data seed. Run from backend with the project venv active."""
from main import SessionLocal, User, Market, FPO, StorageFacility, TransportOption, pwd

s = SessionLocal()
try:
    if not s.query(User).filter_by(email='gov@agrinova.local').first():
        s.add(User(name='AgriNova Government Monitor', email='gov@agrinova.local', password_hash=pwd.hash('AgriNova123!'), role='GOVERNMENT', country='India', location='Pune', verified=True))
    if not s.query(User).filter_by(email='buyer@agrinova.local').first():
        s.add(User(name='Demo Bulk Buyer', email='buyer@agrinova.local', password_hash=pwd.hash('AgriNova123!'), role='BULK_BUYER', country='India', location='Mumbai', verified=True))
    s.commit()
    if s.query(Market).count() == 0:
        s.add_all([
            Market(name='Pune APMC', location='Pune', crop_name='Tomato', price_per_kg=32, market_type='MANDI'),
            Market(name='Nashik Market', location='Nashik', crop_name='Tomato', price_per_kg=35, market_type='MANDI'),
            Market(name='Mumbai Wholesale', location='Mumbai', crop_name='Tomato', price_per_kg=38, market_type='WHOLESALE'),
        ])
        s.commit()
    print('AgriNova demo data ready.')
finally:
    s.close()
