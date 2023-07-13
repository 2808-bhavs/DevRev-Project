from sqlalchemy import Column, String, Integer
from models.base_model import BaseModel
from sqlalchemy.dialects.postgresql import UUID
import uuid
class Booking(BaseModel):
    __tablename__ = "booking"
    booking_id = Column(Integer,primary_key = True, nullable = False)
    journey_id = Column(Integer, nullable = False)
