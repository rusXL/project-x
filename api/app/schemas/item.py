from enum import IntEnum

from pydantic import BaseModel, ConfigDict


class ItemState(IntEnum):
    incomplete = 0
    complete = 1


class ItemCreate(BaseModel):
    value: str


class ItemResponse(BaseModel):
    id: int
    value: str
    state: ItemState

    model_config = ConfigDict(from_attributes=True)
