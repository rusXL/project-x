from typing import List

from fastapi import APIRouter, Depends, HTTPException, Response
from sqlalchemy.orm import Session

from app.config import settings
from app.dependencies import get_db
from app.models.item import Item
from app.schemas.item import ItemCreate, ItemResponse, ItemState

router = APIRouter(prefix="/items", tags=["items"])


@router.get("", response_model=List[ItemResponse])
def list_items(db: Session = Depends(get_db)):
    return db.query(Item).all()


@router.post("", response_model=ItemResponse, status_code=201)
def create_item(payload: ItemCreate, db: Session = Depends(get_db)):
    if len(payload.value) > 255:
        raise HTTPException(status_code=400, detail="Value exceeds maximum length of 255 characters")

    count = db.query(Item.id).limit(settings.max_items + 1).count()
    if count >= settings.max_items:
        raise HTTPException(status_code=400, detail=f"Maximum number of items ({settings.max_items:,}) reached")

    existing = db.query(Item).filter(Item.value == payload.value).first()
    if existing:
        raise HTTPException(status_code=400, detail="An item with this value already exists")

    item = Item(value=payload.value)
    db.add(item)
    db.commit()
    db.refresh(item)
    return item


@router.post("/{item_id}/toggle", response_model=ItemResponse)
def toggle_item(item_id: int, db: Session = Depends(get_db)):
    item = db.query(Item).filter(Item.id == item_id).first()
    if not item:
        raise HTTPException(status_code=404, detail=f"Item with id {item_id} not found")

    item.state = ItemState.complete if item.state == ItemState.incomplete else ItemState.incomplete
    db.commit()
    db.refresh(item)
    return item


@router.delete("/{item_id}", status_code=204)
def delete_item(item_id: int, db: Session = Depends(get_db)):
    item = db.query(Item).filter(Item.id == item_id).first()
    if not item:
        raise HTTPException(status_code=404, detail=f"Item with id {item_id} not found")

    db.delete(item)
    db.commit()
    return Response(status_code=204)
