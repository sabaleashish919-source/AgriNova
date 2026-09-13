import os
from datetime import datetime, timedelta
from enum import Enum
from typing import Optional

from fastapi import Depends, FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from fastapi.security import OAuth2PasswordBearer, OAuth2PasswordRequestForm
from jose import JWTError, jwt
from passlib.context import CryptContext
from pydantic import BaseModel, EmailStr, ConfigDict
from sqlalchemy import (
    Boolean,
    DateTime,
    Float,
    ForeignKey,
    Integer,
    String,
    create_engine,
    func,
)
from sqlalchemy.orm import (
    DeclarativeBase,
    Mapped,
    Session,
    mapped_column,
    sessionmaker,
)


# ============================================================
# CONFIGURATION
# ============================================================

SECRET_KEY = os.getenv(
    "AGROSURPLUS_SECRET_KEY",
    "CHANGE_THIS_IN_PRODUCTION",
)

ALGORITHM = "HS256"

DB_URL = os.getenv(
    "AGROSURPLUS_DB_URL",
    "sqlite:///./agrosurplus.db",
)

# Default domestic demand estimate per crop.
#
# Example:
# If wheat supply = 5,000 kg and estimated domestic demand = 5,000 kg:
#
# surplus = 0 kg
# surplus percentage = 0%
# international market = CLOSED
#
# Change this value later when we build the admin demand-management screen.
DOMESTIC_DEMAND_ESTIMATE_KG = float(
    os.getenv(
        "AGROSURPLUS_DOMESTIC_DEMAND_KG",
        "5000",
    )
)

# International marketplace opens only when surplus reaches this percentage.
#
# 0.20 = 20%
SURPLUS_THRESHOLD = float(
    os.getenv(
        "AGROSURPLUS_SURPLUS_THRESHOLD",
        "0.20",
    )
)


# ============================================================
# DATABASE
# ============================================================

engine = create_engine(
    DB_URL,
    connect_args={"check_same_thread": False},
)

SessionLocal = sessionmaker(
    bind=engine,
    autoflush=False,
    autocommit=False,
)


class Base(DeclarativeBase):
    pass


# ============================================================
# ENUMS
# ============================================================

class Role(str, Enum):
    FARMER = "FARMER"
    CONSUMER = "CONSUMER"
    INTERNATIONAL_BUYER = "INTERNATIONAL_BUYER"
    ADMIN = "ADMIN"


# ============================================================
# DATABASE MODELS
# ============================================================

class User(Base):
    __tablename__ = "users"

    id: Mapped[int] = mapped_column(
        Integer,
        primary_key=True,
    )

    name: Mapped[str] = mapped_column(
        String(120),
    )

    email: Mapped[str] = mapped_column(
        String(255),
        unique=True,
        index=True,
    )

    password_hash: Mapped[str] = mapped_column(
        String(255),
    )

    role: Mapped[str] = mapped_column(
        String(40),
    )

    country: Mapped[Optional[str]] = mapped_column(
        String(100),
        nullable=True,
    )

    location: Mapped[Optional[str]] = mapped_column(
        String(150),
        nullable=True,
    )

    verified: Mapped[bool] = mapped_column(
        Boolean,
        default=False,
    )


class Product(Base):
    __tablename__ = "products"

    id: Mapped[int] = mapped_column(
        Integer,
        primary_key=True,
    )

    farmer_id: Mapped[int] = mapped_column(
        ForeignKey("users.id"),
    )

    crop_name: Mapped[str] = mapped_column(
        String(100),
        index=True,
    )

    quantity_kg: Mapped[float] = mapped_column(
        Float,
    )

    price_per_kg: Mapped[float] = mapped_column(
        Float,
    )

    quality_grade: Mapped[str] = mapped_column(
        String(30),
    )

    farming_type: Mapped[str] = mapped_column(
        String(30),
    )

    location: Mapped[str] = mapped_column(
        String(150),
    )

    harvest_date: Mapped[Optional[str]] = mapped_column(
        String(30),
        nullable=True,
    )

    export_only: Mapped[bool] = mapped_column(
        Boolean,
        default=False,
    )

    active: Mapped[bool] = mapped_column(
        Boolean,
        default=True,
    )

    created_at: Mapped[datetime] = mapped_column(
        DateTime,
        default=datetime.utcnow,
    )


class Order(Base):
    __tablename__ = "orders"

    id: Mapped[int] = mapped_column(
        Integer,
        primary_key=True,
    )

    product_id: Mapped[int] = mapped_column(
        ForeignKey("products.id"),
    )

    buyer_id: Mapped[int] = mapped_column(
        ForeignKey("users.id"),
    )

    quantity_kg: Mapped[float] = mapped_column(
        Float,
    )

    total_amount: Mapped[float] = mapped_column(
        Float,
    )

    status: Mapped[str] = mapped_column(
        String(30),
        default="PENDING",
    )

    created_at: Mapped[datetime] = mapped_column(
        DateTime,
        default=datetime.utcnow,
    )


class Offer(Base):
    __tablename__ = "offers"

    id: Mapped[int] = mapped_column(
        Integer,
        primary_key=True,
    )

    product_id: Mapped[int] = mapped_column(
        ForeignKey("products.id"),
    )

    buyer_id: Mapped[int] = mapped_column(
        ForeignKey("users.id"),
    )

    quantity_kg: Mapped[float] = mapped_column(
        Float,
    )

    price_per_kg: Mapped[float] = mapped_column(
        Float,
    )

    status: Mapped[str] = mapped_column(
        String(30),
        default="PENDING",
    )

    created_at: Mapped[datetime] = mapped_column(
        DateTime,
        default=datetime.utcnow,
    )


Base.metadata.create_all(engine)


# ============================================================
# SECURITY
# ============================================================

pwd = CryptContext(
    schemes=["bcrypt"],
    deprecated="auto",
)

oauth2 = OAuth2PasswordBearer(
    tokenUrl="/api/v1/auth/login",
)


def create_access_token(user: User) -> str:
    payload = {
        "sub": str(user.id),
        "exp": datetime.utcnow() + timedelta(hours=24),
    }

    return jwt.encode(
        payload,
        SECRET_KEY,
        algorithm=ALGORITHM,
    )


# ============================================================
# DATABASE DEPENDENCY
# ============================================================

def db():
    session = SessionLocal()

    try:
        yield session
    finally:
        session.close()


# ============================================================
# AUTHENTICATION
# ============================================================

def current_user(
    token: str = Depends(oauth2),
    session: Session = Depends(db),
) -> User:

    try:
        payload = jwt.decode(
            token,
            SECRET_KEY,
            algorithms=[ALGORITHM],
        )

        user_id = int(payload["sub"])

    except (
        JWTError,
        ValueError,
        KeyError,
        TypeError,
    ):
        raise HTTPException(
            status_code=401,
            detail="Invalid or expired token",
        )

    user = session.get(User, user_id)

    if not user:
        raise HTTPException(
            status_code=401,
            detail="User not found",
        )

    return user


# ============================================================
# PYDANTIC SCHEMAS
# ============================================================

class RegisterIn(BaseModel):
    name: str
    email: EmailStr
    password: str
    role: Role
    country: Optional[str] = None
    location: Optional[str] = None


class UserOut(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: int
    name: str
    email: EmailStr
    role: str
    country: Optional[str]
    location: Optional[str]
    verified: bool


class ProductIn(BaseModel):
    crop_name: str
    quantity_kg: float
    price_per_kg: float
    quality_grade: str = "A"
    farming_type: str = "Conventional"
    location: str
    harvest_date: Optional[str] = None


class ProductOut(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: int
    farmer_id: int
    crop_name: str
    quantity_kg: float
    price_per_kg: float
    quality_grade: str
    farming_type: str
    location: str
    harvest_date: Optional[str]
    export_only: bool
    active: bool


class OrderIn(BaseModel):
    product_id: int
    quantity_kg: float


class OrderOut(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: int
    product_id: int
    buyer_id: int
    quantity_kg: float
    total_amount: float
    status: str
    created_at: datetime


class OfferIn(BaseModel):
    product_id: int
    quantity_kg: float
    price_per_kg: float


class OfferOut(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: int
    product_id: int
    buyer_id: int
    quantity_kg: float
    price_per_kg: float
    status: str
    created_at: datetime


# ============================================================
# FASTAPI APP
# ============================================================

app = FastAPI(
    title="AgroSurplus API",
    version="1.0.0",
)


app.add_middleware(
    CORSMiddleware,
    allow_origin_regex=r"https?://(localhost|127\.0\.0\.1)(:\d+)?$",
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


# ============================================================
# HEALTH CHECK
# ============================================================

@app.get("/api/v1/health")
def health():
    return {
        "status": "ok",
        "service": "AgroSurplus API",
    }


# ============================================================
# AUTH - REGISTER
# ============================================================

@app.post(
    "/api/v1/auth/register",
    response_model=UserOut,
)
def register(
    data: RegisterIn,
    session: Session = Depends(db),
):

    existing_user = (
        session
        .query(User)
        .filter_by(email=str(data.email))
        .first()
    )

    if existing_user:
        raise HTTPException(
            status_code=409,
            detail="Email already registered",
        )

    if len(data.password) < 8:
        raise HTTPException(
            status_code=422,
            detail="Password must contain at least 8 characters",
        )

    user = User(
        name=data.name.strip(),
        email=str(data.email).lower(),
        password_hash=pwd.hash(data.password),
        role=data.role.value,
        country=data.country.strip() if data.country else None,
        location=data.location.strip() if data.location else None,
        verified=True,
    )

    session.add(user)
    session.commit()
    session.refresh(user)

    return user


# ============================================================
# AUTH - LOGIN
# ============================================================

@app.post("/api/v1/auth/login")
def login(
    form: OAuth2PasswordRequestForm = Depends(),
    session: Session = Depends(db),
):

    user = (
        session
        .query(User)
        .filter_by(email=form.username.lower())
        .first()
    )

    if not user:
        raise HTTPException(
            status_code=401,
            detail="Invalid email or password",
        )

    if not pwd.verify(
        form.password,
        user.password_hash,
    ):
        raise HTTPException(
            status_code=401,
            detail="Invalid email or password",
        )

    return {
        "access_token": create_access_token(user),
        "token_type": "bearer",
        "user": UserOut.model_validate(user).model_dump(),
    }


# ============================================================
# AUTH - CURRENT USER
# ============================================================

@app.get(
    "/api/v1/auth/me",
    response_model=UserOut,
)
def me(
    user: User = Depends(current_user),
):
    return user


# ============================================================
# SURPLUS ENGINE
# ============================================================

def calculate_crop_market_status(
    session: Session,
    crop_name: str,
):
    """
    Calculate supply, demand and surplus for one crop.

    Domestic demand is represented by the configurable MVP
    estimate plus actual completed/pending domestic orders.

    The international market opens when:

        surplus / domestic_demand >= threshold
    """

    supply = (
        session
        .query(func.coalesce(func.sum(Product.quantity_kg), 0.0))
        .filter(
            Product.active.is_(True),
            Product.crop_name == crop_name,
        )
        .scalar()
        or 0.0
    )

    domestic_orders = (
        session
        .query(func.coalesce(func.sum(Order.quantity_kg), 0.0))
        .join(
            Product,
            Order.product_id == Product.id,
        )
        .filter(
            Product.crop_name == crop_name,
            Order.status.in_(["PENDING", "CONFIRMED", "COMPLETED"]),
        )
        .scalar()
        or 0.0
    )

    # We always retain the configured domestic market estimate.
    domestic_demand = max(
        DOMESTIC_DEMAND_ESTIMATE_KG,
        float(domestic_orders),
    )

    surplus = max(
        float(supply) - domestic_demand,
        0.0,
    )

    surplus_percentage = (
        surplus / domestic_demand
        if domestic_demand > 0
        else 0.0
    )

    international_open = (
        surplus_percentage >= SURPLUS_THRESHOLD
    )

    return {
        "crop_name": crop_name,
        "total_supply_kg": float(supply),
        "domestic_demand_kg": float(domestic_demand),
        "surplus_kg": float(surplus),
        "surplus_percentage": float(surplus_percentage),
        "threshold": SURPLUS_THRESHOLD,
        "international_market_open": international_open,
    }


def refresh_export_flags(
    session: Session,
):
    """
    Recalculate export_only for every active crop.

    A crop becomes export-only only when THAT crop has
    reached the configured surplus threshold.
    """

    crop_names = (
        session
        .query(Product.crop_name)
        .filter(Product.active.is_(True))
        .distinct()
        .all()
    )

    for row in crop_names:

        crop_name = row[0]

        status = calculate_crop_market_status(
            session,
            crop_name,
        )

        products = (
            session
            .query(Product)
            .filter(
                Product.active.is_(True),
                Product.crop_name == crop_name,
            )
            .all()
        )

        for product in products:
            product.export_only = status[
                "international_market_open"
            ]

    session.commit()


# ============================================================
# PRODUCTS - MARKETPLACE
# ============================================================

@app.get(
    "/api/v1/products",
    response_model=list[ProductOut],
)
def products(
    export_only: bool = False,
    session: Session = Depends(db),
    user: User = Depends(current_user),
):

    # Make sure export status is current.
    refresh_export_flags(session)

    query = (
        session
        .query(Product)
        .filter(
            Product.active.is_(True),
            Product.quantity_kg > 0,
        )
    )

    if export_only:
        query = query.filter(
            Product.export_only.is_(True)
        )

    # Domestic consumers should not see export-only products
    # as normal buyable products.
    if user.role == "CONSUMER":
        query = query.filter(
            Product.export_only.is_(False)
        )

    return (
        query
        .order_by(Product.created_at.desc())
        .all()
    )


# ============================================================
# PRODUCTS - FARMER PRODUCTS
# ============================================================

@app.get(
    "/api/v1/products/mine",
    response_model=list[ProductOut],
)
def my_products(
    session: Session = Depends(db),
    user: User = Depends(current_user),
):

    if user.role != "FARMER":
        raise HTTPException(
            status_code=403,
            detail="Farmer access required",
        )

    refresh_export_flags(session)

    return (
        session
        .query(Product)
        .filter_by(farmer_id=user.id)
        .order_by(Product.created_at.desc())
        .all()
    )


# ============================================================
# PRODUCTS - ADD
# ============================================================

@app.post(
    "/api/v1/products",
    response_model=ProductOut,
)
def add_product(
    data: ProductIn,
    session: Session = Depends(db),
    user: User = Depends(current_user),
):

    if user.role != "FARMER":
        raise HTTPException(
            status_code=403,
            detail="Farmer access required",
        )

    if not data.crop_name.strip():
        raise HTTPException(
            status_code=422,
            detail="Crop name is required",
        )

    if data.quantity_kg <= 0:
        raise HTTPException(
            status_code=422,
            detail="Quantity must be greater than zero",
        )

    if data.price_per_kg <= 0:
        raise HTTPException(
            status_code=422,
            detail="Price must be greater than zero",
        )

    if not data.location.strip():
        raise HTTPException(
            status_code=422,
            detail="Location is required",
        )

    product = Product(
        farmer_id=user.id,
        crop_name=data.crop_name.strip(),
        quantity_kg=data.quantity_kg,
        price_per_kg=data.price_per_kg,
        quality_grade=data.quality_grade.strip(),
        farming_type=data.farming_type.strip(),
        location=data.location.strip(),
        harvest_date=data.harvest_date,
        export_only=False,
        active=True,
    )

    session.add(product)
    session.commit()
    session.refresh(product)

    refresh_export_flags(session)

    session.refresh(product)

    return product


# ============================================================
# PRODUCTS - EDIT
# ============================================================

@app.put(
    "/api/v1/products/{product_id}",
    response_model=ProductOut,
)
def edit_product(
    product_id: int,
    data: ProductIn,
    session: Session = Depends(db),
    user: User = Depends(current_user),
):

    if user.role != "FARMER":
        raise HTTPException(
            status_code=403,
            detail="Farmer access required",
        )

    product = session.get(
        Product,
        product_id,
    )

    if not product or product.farmer_id != user.id:
        raise HTTPException(
            status_code=404,
            detail="Product not found",
        )

    if data.quantity_kg <= 0:
        raise HTTPException(
            status_code=422,
            detail="Quantity must be greater than zero",
        )

    if data.price_per_kg <= 0:
        raise HTTPException(
            status_code=422,
            detail="Price must be greater than zero",
        )

    product.crop_name = data.crop_name.strip()
    product.quantity_kg = data.quantity_kg
    product.price_per_kg = data.price_per_kg
    product.quality_grade = data.quality_grade.strip()
    product.farming_type = data.farming_type.strip()
    product.location = data.location.strip()
    product.harvest_date = data.harvest_date

    session.commit()
    session.refresh(product)

    refresh_export_flags(session)

    session.refresh(product)

    return product


# ============================================================
# PRODUCTS - DELETE
# ============================================================

@app.delete("/api/v1/products/{product_id}")
def delete_product(
    product_id: int,
    session: Session = Depends(db),
    user: User = Depends(current_user),
):

    if user.role != "FARMER":
        raise HTTPException(
            status_code=403,
            detail="Farmer access required",
        )

    product = session.get(
        Product,
        product_id,
    )

    if not product or product.farmer_id != user.id:
        raise HTTPException(
            status_code=404,
            detail="Product not found",
        )

    product.active = False
    product.quantity_kg = 0

    session.commit()

    refresh_export_flags(session)

    return {
        "message": "Product deleted",
    }


# ============================================================
# ORDERS - CREATE
# ============================================================

@app.post(
    "/api/v1/orders",
    response_model=OrderOut,
)
def create_order(
    data: OrderIn,
    session: Session = Depends(db),
    user: User = Depends(current_user),
):

    if user.role != "CONSUMER":
        raise HTTPException(
            status_code=403,
            detail="Consumer access required",
        )

    if data.quantity_kg <= 0:
        raise HTTPException(
            status_code=422,
            detail="Order quantity must be greater than zero",
        )

    # Recalculate market status before allowing the purchase.
    refresh_export_flags(session)

    product = session.get(
        Product,
        data.product_id,
    )

    if not product:
        raise HTTPException(
            status_code=404,
            detail="Product not found",
        )

    if not product.active:
        raise HTTPException(
            status_code=404,
            detail="Product is no longer available",
        )

    if product.quantity_kg <= 0:
        raise HTTPException(
            status_code=404,
            detail="Product is sold out",
        )

    if product.export_only:
        raise HTTPException(
            status_code=403,
            detail=(
                "This product is currently reserved for "
                "the international marketplace because "
                "the crop has reached the surplus threshold."
            ),
        )

    if data.quantity_kg > product.quantity_kg:
        raise HTTPException(
            status_code=422,
            detail=(
                f"Only {product.quantity_kg:.2f} kg "
                "is currently available."
            ),
        )

    total_amount = (
        data.quantity_kg * product.price_per_kg
    )

    product.quantity_kg -= data.quantity_kg

    # If nothing remains, make the product inactive.
    if product.quantity_kg <= 0:
        product.quantity_kg = 0
        product.active = False

    order = Order(
        product_id=product.id,
        buyer_id=user.id,
        quantity_kg=data.quantity_kg,
        total_amount=total_amount,
        status="PENDING",
    )

    session.add(order)
    session.commit()
    session.refresh(order)

    # Recalculate after the purchase.
    refresh_export_flags(session)

    return order


# ============================================================
# ORDERS - LIST
# ============================================================

@app.get(
    "/api/v1/orders",
    response_model=list[OrderOut],
)
def get_orders(
    session: Session = Depends(db),
    user: User = Depends(current_user),
):

    refresh_export_flags(session)

    if user.role == "CONSUMER":

        return (
            session
            .query(Order)
            .filter(
                Order.buyer_id == user.id,
            )
            .order_by(Order.created_at.desc())
            .all()
        )

    if user.role == "FARMER":

        return (
            session
            .query(Order)
            .join(
                Product,
                Order.product_id == Product.id,
            )
            .filter(
                Product.farmer_id == user.id,
            )
            .order_by(Order.created_at.desc())
            .all()
        )

    raise HTTPException(
        status_code=403,
        detail="Orders are available to consumers and farmers",
    )


# ============================================================
# MARKET SUMMARY
# ============================================================

@app.get("/api/v1/market/summary")
def market_summary(
    session: Session = Depends(db),
    user: User = Depends(current_user),
):

    refresh_export_flags(session)

    active_products = (
        session
        .query(Product)
        .filter(
            Product.active.is_(True),
        )
        .all()
    )

    crop_names = sorted(
        {
            product.crop_name
            for product in active_products
        }
    )

    crop_statuses = [
        calculate_crop_market_status(
            session,
            crop_name,
        )
        for crop_name in crop_names
    ]

    total_supply = sum(
        item["total_supply_kg"]
        for item in crop_statuses
    )

    total_demand = sum(
        item["domestic_demand_kg"]
        for item in crop_statuses
    )

    total_surplus = sum(
        item["surplus_kg"]
        for item in crop_statuses
    )

    overall_percentage = (
        total_surplus / total_demand
        if total_demand > 0
        else 0.0
    )

    international_open = any(
        item["international_market_open"]
        for item in crop_statuses
    )

    return {
        "total_supply_kg": total_supply,
        "domestic_demand_kg": total_demand,
        "surplus_kg": total_surplus,
        "surplus_percentage": overall_percentage,
        "threshold": SURPLUS_THRESHOLD,
        "international_market_open": international_open,
        "domestic_demand_estimate_per_crop_kg": (
            DOMESTIC_DEMAND_ESTIMATE_KG
        ),
        "crops": crop_statuses,
    }


# ============================================================
# INTERNATIONAL BUYER - OFFERS
# ============================================================

@app.get(
    "/api/v1/international/offers",
    response_model=list[OfferOut],
)
def get_offers(
    session: Session = Depends(db),
    user: User = Depends(current_user),
):

    if user.role != "INTERNATIONAL_BUYER":
        raise HTTPException(
            status_code=403,
            detail="International buyer access required",
        )

    return (
        session
        .query(Offer)
        .filter(
            Offer.buyer_id == user.id,
        )
        .order_by(Offer.created_at.desc())
        .all()
    )


# ============================================================
# INTERNATIONAL BUYER - MAKE OFFER
# ============================================================

@app.post(
    "/api/v1/international/offers",
    response_model=OfferOut,
)
def make_offer(
    data: OfferIn,
    session: Session = Depends(db),
    user: User = Depends(current_user),
):

    if user.role != "INTERNATIONAL_BUYER":
        raise HTTPException(
            status_code=403,
            detail="International buyer access required",
        )

    if data.quantity_kg <= 0:
        raise HTTPException(
            status_code=422,
            detail="Quantity must be greater than zero",
        )

    if data.price_per_kg <= 0:
        raise HTTPException(
            status_code=422,
            detail="Price must be greater than zero",
        )

    refresh_export_flags(session)

    product = session.get(
        Product,
        data.product_id,
    )

    if not product:
        raise HTTPException(
            status_code=404,
            detail="Product not found",
        )

    if not product.active:
        raise HTTPException(
            status_code=404,
            detail="Product is not available",
        )

    if not product.export_only:
        raise HTTPException(
            status_code=403,
            detail=(
                "International offers are only available "
                "when the crop reaches the surplus threshold."
            ),
        )

    if data.quantity_kg > product.quantity_kg:
        raise HTTPException(
            status_code=422,
            detail=(
                f"Only {product.quantity_kg:.2f} kg "
                "is available."
            ),
        )

    offer = Offer(
        product_id=product.id,
        buyer_id=user.id,
        quantity_kg=data.quantity_kg,
        price_per_kg=data.price_per_kg,
        status="PENDING",
    )

    session.add(offer)
    session.commit()
    session.refresh(offer)

    return offer