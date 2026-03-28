from sqlalchemy.ext.asyncio import AsyncSession, async_sessionmaker, create_async_engine
from sqlalchemy.orm import DeclarativeBase

from app.config import settings

engine = create_async_engine(settings.database_url, pool_size=10, max_overflow=20)
SessionLocal = async_sessionmaker(
    class_=AsyncSession, autocommit=False, autoflush=False, bind=engine
)


class Base(DeclarativeBase):
    pass
