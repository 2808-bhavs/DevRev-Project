from sqlalchemy import Column,VARCHAR,Boolean
from models.base_model import BaseModel

class Login(BaseModel):
    __tablename__ = "login"
    email = Column(VARCHAR(100), primary_key = True, nullable = False)
    password = Column(VARCHAR(20),nullable = False)
    is_admin = Column(Boolean,nullable = False)