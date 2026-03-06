from sqlalchemy import Column, Integer, String

from app.database import Base
from app.schemas.item import ItemState


class Item(Base):
    __tablename__ = "items"

    id = Column(Integer, primary_key=True, autoincrement=True)
    value = Column(String(255), unique=True, nullable=False)
    state = Column(Integer, default=ItemState.incomplete, nullable=False)
