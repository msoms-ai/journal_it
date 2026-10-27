from typing import Generator
from sqlalchemy import create_engine
from sqlalchemy.orm import declarative_base, sessionmaker, Session
from src.core.config import settings

# For SQLite, ensure check_same_thread=False
connect_args = {}
if settings.DATABASE_URL.startswith("sqlite"):
    connect_args = {"check_same_thread": False}

engine = create_engine(
    settings.DATABASE_URL,
    connect_args=connect_args,
    pool_pre_ping=True
)

SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

Base = declarative_base()

def get_db() -> Generator[Session, None, None]:
    """
    Database session dependency.
    In PostgreSQL, this can execute SET LOCAL app.current_tenant_id
    """
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()
