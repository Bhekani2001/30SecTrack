from pydantic import BaseModel, Field
from typing import Optional
from datetime import datetime

class LocationCreate(BaseModel):
    unit_id: str = Field(..., example="unit123")
    latitude: float = Field(..., example=37.7749)
    longitude: float = Field(..., example=-122.4194)
    timestamp: Optional[datetime] = Field(None, example="2025-07-14T10:30:00Z")

class LocationUpdate(BaseModel):
    unit_id: Optional[str] = None
    latitude: Optional[float] = None
    longitude: Optional[float] = None
    timestamp: Optional[datetime] = None

class LocationOut(BaseModel):
    id: int
    unit_id: str
    latitude: float
    longitude: float
    timestamp: datetime

    class Config:
        orm_mode = True
