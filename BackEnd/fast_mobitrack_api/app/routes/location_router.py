from fastapi import APIRouter, Depends, HTTPException, status, Header
from sqlalchemy.orm import Session
from app.database.database import SessionLocal
from app.schemas.location_schema import LocationCreate, LocationOut
from app.repositories.location_repo import LocationRepo
from app.services.location_service import LocationService
from app.utils.security import jwt, SECRET_KEY, ALGORITHM
from jose import JWTError
from typing import List

router = APIRouter(prefix="/location", tags=["Location"])

def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

def get_current_user(authorization: str = Header(None), db: Session = Depends(get_db)):
    if not authorization or not authorization.startswith("Bearer "):
        raise HTTPException(status_code=401, detail="Not authenticated")
    token = authorization.split(" ")[1]
    try:
        payload = jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])
        user_id = int(payload.get("sub"))
        return user_id
    except JWTError:
        raise HTTPException(status_code=401, detail="Invalid token")

@router.post("/", response_model=LocationOut, status_code=201)
def save_location(
    location: LocationCreate,
    db: Session = Depends(get_db),
    user_id: int = Depends(get_current_user)
):
    
    service = LocationService(LocationRepo(db))
    try:
        loc = service.save_location(user_id, location.latitude, location.longitude, location.timestamp)
        return loc
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))

@router.get("/", response_model=List[LocationOut], status_code=200)
def get_locations(
    db: Session = Depends(get_db),
    user_id: int = Depends(get_current_user)
):
    service = LocationService(LocationRepo(db))
    return service.get_locations(user_id)