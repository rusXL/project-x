from typing import List

from fastapi import APIRouter, Depends, HTTPException, Response
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, func

from app.config import settings
from app.dependencies import get_db
from app.models.item import Item
from app.schemas.item import ItemCreate, ItemResponse, ItemState

router = APIRouter(prefix="/items", tags=["items"])


@router.get("", response_model=List[ItemResponse])
async def list_items(db: AsyncSession = Depends(get_db)):
    result = await db.execute(select(Item))
    return result.scalars().all()


@router.post("", response_model=ItemResponse, status_code=201)
async def create_item(payload: ItemCreate, db: AsyncSession = Depends(get_db)):
    if len(payload.value) > 255:
        raise HTTPException(
            status_code=400, detail="Value exceeds maximum length of 255 characters"
        )

    result = await db.execute(select(func.count(Item.id)).limit(settings.max_items + 1))
    count = result.scalar()
    if count >= settings.max_items:
        raise HTTPException(
            status_code=400,
            detail=f"Maximum number of items ({settings.max_items:,}) reached",
        )

    item = Item(value=payload.value)
    db.add(item)
    await db.commit()
    await db.refresh(item)
    return item


@router.post("/{item_id}/toggle", response_model=ItemResponse)
async def toggle_item(item_id: int, db: AsyncSession = Depends(get_db)):
    result = await db.execute(select(Item).where(Item.id == item_id))
    item = result.scalars().first()
    if not item:
        raise HTTPException(status_code=404, detail=f"Item with id {item_id} not found")

    item.state = (
        ItemState.complete
        if item.state == ItemState.incomplete
        else ItemState.incomplete
    )
    await db.commit()
    await db.refresh(item)
    return item


@router.delete("/{item_id}", status_code=204)
async def delete_item(item_id: int, db: AsyncSession = Depends(get_db)):
    result = await db.execute(select(Item).where(Item.id == item_id))
    item = result.scalars().first()
    if not item:
        raise HTTPException(status_code=404, detail=f"Item with id {item_id} not found")

    await db.delete(item)
    await db.commit()
    return Response(status_code=204)
