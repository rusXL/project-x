from contextlib import asynccontextmanager

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from sqlalchemy import select
from prometheus_fastapi_instrumentator import Instrumentator

from app.config import settings
from app.database import Base, engine, SessionLocal
from app.models.item import Item
from app.routers import items


async def _create_database() -> None:
    root_url = settings.database_url.rsplit("/", 1)[0]
    root_engine = create_async_engine(root_url)
    async with root_engine.begin() as conn:
        await conn.execute(text(f"CREATE DATABASE IF NOT EXISTS `agama`"))
    await root_engine.dispose()


async def _create_tables() -> None:
    async with engine.begin() as conn:
        await conn.run_sync(Base.metadata.create_all)


async def _seed_demo_items() -> None:
    async with SessionLocal() as db:
        result = await db.execute(select(Item))
        if not result.scalars().first():
            db.add_all(
                [
                    Item(
                        value="I'm a demo item — click me to change my state", state=1
                    ),
                    Item(value="I'm another demo item — click ❌ to remove me →"),
                ]
            )
            await db.commit()


@asynccontextmanager
async def lifespan(app: FastAPI):
    await _create_database()
    await _create_tables()
    await _seed_demo_items()
    yield


app = FastAPI(title=settings.app_name, lifespan=lifespan)

app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.allowed_origins,
    allow_methods=["*"],
    allow_headers=["*"],
)

Instrumentator().instrument(app).expose(app)

app.include_router(items.router)


@app.get("/health")
def health():
    return {"status": "ok"}
