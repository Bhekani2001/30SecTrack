from sqlalchemy.orm import Session
from app.models.user import User
from app.repositories.interfaces import IUserRepo

class UserRepo(IUserRepo):
    def __init__(self, db: Session):
        self.db = db

    def get_by_email(self, email: str):
        return self.db.query(User).filter(User.email == email).first()

    def create(self, name: str, email: str, hashed_password: str):
        user = User(name=name, email=email, hashed_password=hashed_password)
        self.db.add(user)
        self.db.commit()
        self.db.refresh(user)
        return user