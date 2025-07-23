from app.repositories.user_repo import UserRepo
from app.utils.security import hash_password, verify_password, create_access_token

class UserService:
    def __init__(self, repo: UserRepo):
        self.repo = repo

    def register(self, name, email, password):
        if self.repo.get_by_email(email):
            raise Exception("Email already registered")
        hashed = hash_password(password)
        return self.repo.create(name, email, hashed)

    def login(self, email, password):
        user = self.repo.get_by_email(email)
        if not user or not verify_password(password, user.hashed_password):
            raise Exception("Invalid credentials")
        return create_access_token({"sub": str(user.id)})