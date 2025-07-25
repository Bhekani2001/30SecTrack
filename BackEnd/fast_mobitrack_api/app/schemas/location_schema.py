from pydantic import BaseModel, Field
from typing import Optional
from datetime import datetime

class LocationCreate(BaseModel):
    latitude: float = Field(..., example=37.7749)
    longitude: float = Field(..., example=-122.4194)
    timestamp: Optional[datetime] = Field(None, example="2024-07-24T12:34:56Z")

class LocationOut(BaseModel):
    id: int
    latitude: float
    longitude: float
    timestamp: datetime

    class Config:
        from_attributes = True  

class LocationUpdate(BaseModel):
    latitude: Optional[float] = Field(None, example=37.7749)
    longitude: Optional[float] = Field(None, example=-122.4194)
    timestamp: Optional[datetime] = Field(None, example="2024-07-24T12:34:56Z")
