import json
from service.DBInit import DB
from models.get_flight import Flight
from models.booking import Booking
from models.login import Login
from sqlalchemy.orm.exc import NoResultFound
from service.custom_exception import Error

"""
 # @Python program 
 # @Author: Bhavya Sree
 # @Name: main.py
 # @Lambda name: lambda_get_booking
 # @Version: 1.0
 # @See: Program to get booking information
"""
""" 
    Title:
        Lambda Handler method to get booking information from the database
"""
def lambda_handler(event,context):
    try:
        connection = DB()
        Session = connection.connect()
        session = Session()
        user = event['params']['header']['email']
        booking_data = session.query(Booking,Flight,Login) \
            .join(Booking, Booking.journey_id == Flight.journey_id) \
            .filter(Login.email == user).all()
        responses = [
                {
                    "bookingId": str(data[0].booking_id),
                    "journeyId": str(data[0].journey_id),
                    "flightNumber": str(data[1].flight_num),
                    "flightName": str(data[1].flight_name),
                    "dateOfJourney": str(data[1].date),
                    "From": str(data[1].journey_from),
                    "To": str(data[1].journey_to),
                    "departureTime": str(data[1].departure_time)[11:16],
                    "arrivalTime": str(data[1].arrival_time)[11:16]
                }
                for data in booking_data
        ]
        if not responses:
            raise NoResultFound()
        
        return responses  
            
    
    except NoResultFound:
        api_exception_obj = {
            "error" : "Bookings not found",
		}
        api_exception_json = json.dumps(api_exception_obj)
        raise Error(api_exception_json)

    except ValueError:
        api_exception_obj = {
            "error" : "Invalid request",
            "errorMessage" : "Missing / Wrong details entered"
		}
        api_exception_json = json.dumps(api_exception_obj)
        raise Error(api_exception_json)

    except Exception:
        api_exception_obj = {
            "error" : "Internal server error",
            "errorMessage" : "Wrong details"
		}
        api_exception_json = json.dumps(api_exception_obj)
        raise Error(api_exception_json)
    finally:
        session.close()	
    