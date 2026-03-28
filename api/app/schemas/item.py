from enum import IntEnum

from typing import Annotated

from pydantic import BaseModel, ConfigDict, PlainSerializer


class ItemState(IntEnum):
    incomplete = 0
    complete = 1


class ItemCreate(BaseModel):
    value: str


StrInt = Annotated[int, PlainSerializer(lambda v: str(v), return_type=str)]


class ItemResponse(BaseModel):
    id: StrInt
    value: str
    state: ItemState

    model_config = ConfigDict(from_attributes=True)
