from sqlalchemy import DateTime,VARCHAR,Column, Boolean
from models.base_model import BaseModel
from models.mapping_templates import AddUser


class Error(Exception):
    pass

class Login(BaseModel):
    __tablename__ = "login"
    email = Column(VARCHAR(30), primary_key=True, nullable = False)
    password = Column(VARCHAR(40),nullable = False)
    is_admin = Column(Boolean,nullable = False)
     
    def login(self,request_payload):
        mapping = AddUser()
        for key,value in request_payload.items():
            if key in mapping.ADD_USER_TEMPLATE:
                cat = mapping.ADD_USER_TEMPLATE[key]
                setattr(self,cat,value)