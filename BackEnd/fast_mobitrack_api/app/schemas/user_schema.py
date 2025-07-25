from pydantic import BaseModel, EmailStr, Field

class UserCreate(BaseModel):
    name: str = Field(..., example="Mr Ngwane")
    email: EmailStr = Field(..., example="ngwane@example.com")
    password: str = Field(..., example="strongpassword123")

class UserLogin(BaseModel):
    email: EmailStr = Field(..., example="ngwane@example.com")
    password: str = Field(..., example="strongpassword123")

class UserOut(BaseModel):
    id: int
    name: str
    email: EmailStr

    class Config:
        from_attributes = True