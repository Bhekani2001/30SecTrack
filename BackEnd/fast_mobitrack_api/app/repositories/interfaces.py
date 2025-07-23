from abc import ABC, abstractmethod

class IUserRepo(ABC):
    @abstractmethod
    def get_by_email(self, email: str): pass

    @abstractmethod
    def create(self, name: str, email: str, hashed_password: str): pass

class ILocationRepo(ABC):
    @abstractmethod
    def create(self, user_id: int, latitude: float, longitude: float, timestamp): pass

    @abstractmethod
    def get_by_user(self, user_id: int): pass