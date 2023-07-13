import sys
from sqlalchemy import Column, String, ForeignKey,DATE, Integer
from models.base_model import BaseModel
from models.mapping_templates import GetFligthMapping


class Flight(BaseModel):
    __tablename__ = "journey"
    journey_id = Column(Integer,primary_key=True,nullable=False)
    flight_num = Column(String(length=20),nullable=False)
    flight_name = Column(String(length=60), nullable = False)
    date = Column(DATE, nullable=False)
    journey_from = Column(String(length=30), nullable = False)
    journey_to= Column(String(length=30), nullable = False)
    departure_time = Column(DATE, nullable=False)
    arrival_time = Column(DATE, nullable=False)  

    def out_payload_get_book(self):
        try:
            response = {

                "journeyId": str(self.journey_id),
                "flightNumber": str(self.flight_name),
                "flightName": str(self.flight_name),
                "dateOfJourney": str(self.date),
                "From": str(self.journey_from),
                "To": str(self.journey_to),
                "departureTime": str(self.departure_time),
                "arrivalTime": str(self.arrival_time)
            }
        except Exception as e :
            exc_type, exc_obj, exc_tb = sys.exc_info()
            print(exc_tb.tb_lineno)
        return response
    def get_flight_request(self, data):
        try:
            mapping = GetFligthMapping()
            for key, value in data.items():
                if key in mapping.GET_FLIGHT_MAPPING_TEMPLATE:
                    flight_key = mapping.GET_FLIGHT_MAPPING_TEMPLATE[key]
                    setattr(self, flight_key, value)
        except Exception as e:
            print(str(e))