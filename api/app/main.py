from contextlib import asynccontextmanager

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from prometheus_fastapi_instrumentator import Instrumentator

from app.config import settings
from app.database import Base, engine, SessionLocal
from app.models.item import Item
from app.routers import items


def _create_tables() -> None:
    Base.metadata.create_all(bind=engine)


def _seed_demo_items() -> None:
    db = SessionLocal()
    try:
        if db.query(Item).count() == 0:
            db.add_all([
                Item(value="I'm a demo item — click me to change my state", state=1),
                Item(value="I'm another demo item — click ❌ to remove me →"),
            ])
            db.commit()
    finally:
        db.close()


@asynccontextmanager
async def lifespan(app: FastAPI):
    _create_tables()
    _seed_demo_items()
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
