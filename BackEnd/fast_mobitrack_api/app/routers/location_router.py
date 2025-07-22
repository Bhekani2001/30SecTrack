from fastapi import APIRouter, Depends, HTTPException, status, Query
from sqlalchemy.orm import Session
from app.database.database import SessionLocal
from app.models.location import Location
from app.schemas.location_schema import LocationCreate, LocationOut, LocationUpdate
@router.get("/location/{location_id}", response_model=LocationOut)
def get_location_by_id(location_id: int, db: Session = Depends(get_db)):
    location = db.query(Location).filter(Location.id == location_id).first()
    if not location:
        raise HTTPException(status_code=404, detail="Location not found")
    return location

@router.patch("/location/{location_id}", response_model=LocationOut)
def update_location(location_id: int, location_update: LocationUpdate, db: Session = Depends(get_db)):
    location = db.query(Location).filter(Location.id == location_id).first()
    if not location:
        raise HTTPException(status_code=404, detail="Location not found")
    for field, value in location_update.dict(exclude_unset=True).items():
        setattr(location, field, value)
    db.commit()
    db.refresh(location)
    return location

@router.delete("/location/{location_id}", status_code=status.HTTP_204_NO_CONTENT)
def delete_location(location_id: int, db: Session = Depends(get_db)):
    location = db.query(Location).filter(Location.id == location_id).first()
    if not location:
        raise HTTPException(status_code=404, detail="Location not found")
    db.delete(location)
    db.commit()
    return None
from typing import List, Optional
import datetime

router = APIRouter()

def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

@router.post("/location", response_model=LocationOut, status_code=status.HTTP_201_CREATED)
def create_location(location: LocationCreate, db: Session = Depends(get_db)):
    db_location = Location(
        unit_id=location.unit_id,
        latitude=location.latitude,
        longitude=location.longitude,
        timestamp=location.timestamp or datetime.datetime.utcnow()
    )
    db.add(db_location)
    db.commit()
    db.refresh(db_location)
    return db_location

@router.get("/locations", response_model=List[LocationOut])
def get_locations(skip: int = 0, limit: int = Query(10, le=100), db: Session = Depends(get_db)):
    locations = db.query(Location).order_by(Location.timestamp.desc()).offset(skip).limit(limit).all()
    return locations

@router.get("/locations/{unit_id}", response_model=List[LocationOut])
def get_locations_by_unit(unit_id: str, skip: int = 0, limit: int = Query(10, le=100), db: Session = Depends(get_db)):
    locations = db.query(Location).filter(Location.unit_id == unit_id).order_by(Location.timestamp.desc()).offset(skip).limit(limit).all()
    if not locations:
        raise HTTPException(status_code=404, detail="No locations found for this unit_id")
    return locations
