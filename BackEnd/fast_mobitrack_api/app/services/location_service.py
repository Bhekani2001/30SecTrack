from app.repositories.location_repo import LocationRepo
from datetime import datetime
from typing import Optional, List
from app.schemas.location_schema import LocationOut

class LocationService:

    def __init__(self, repo: LocationRepo):
        self.repo = repo

    def save_location(
        self,
        user_id: int,
        latitude: float,
        longitude: float,
        timestamp: Optional[datetime] = None
    ) -> LocationOut:
     
        if not (-90 <= latitude <= 90):
            raise ValueError("Latitude must be between -90 and 90.")
        if not (-180 <= longitude <= 180):
            raise ValueError("Longitude must be between -180 and 180.")
        if timestamp is None:
            timestamp = datetime.utcnow()
        return self.repo.create(user_id, latitude, longitude, timestamp)

    def get_locations(self, user_id: int) -> List[LocationOut]:

        return self.repo.get_by_user(user_id)