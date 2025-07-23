from app.repositories.location_repo import LocationRepo

class LocationService:
    def __init__(self, repo: LocationRepo):
        self.repo = repo

    def save_location(self, user_id, latitude, longitude, timestamp):
        return self.repo.create(user_id, latitude, longitude, timestamp)

    def get_locations(self, user_id):
        return self.repo.get_by_user(user_id)