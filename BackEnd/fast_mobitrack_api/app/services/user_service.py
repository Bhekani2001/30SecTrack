from app.repositories.user_repo import UserRepo
from app.utils.security import hash_password, verify_password, create_access_token
from typing import Optional, Dict, Any

class UserService:

    def __init__(self, repo: UserRepo):

        self.repo = repo

    def register(self, name: str, email: str, password: str) -> Any:

        if self.repo.get_by_email(email):
            raise ValueError("Email already registered")
        hashed = hash_password(password)
        return self.repo.create(name, email, hashed)

    def login(self, email: str, password: str) -> str:
        user = self.repo.get_by_email(email)
        if not user or not verify_password(password, user.hashed_password):
            raise ValueError("Invalid credentials")
        return create_access_token({"sub": str(user.id)})