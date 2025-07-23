from sqlalchemy.orm import Session
from app.models.location import Location
from app.repositories.interfaces import ILocationRepo

class LocationRepo(ILocationRepo):
    def __init__(self, db: Session):
        self.db = db

    def create(self, user_id: int, latitude: float, longitude: float, timestamp):
        location = Location(user_id=user_id, latitude=latitude, longitude=longitude, timestamp=timestamp)
        self.db.add(location)
        self.db.commit()
        self.db.refresh(location)
        return location

    def get_by_user(self, user_id: int):
        return self.db.query(Location).filter(Location.user_id == user_id).all()