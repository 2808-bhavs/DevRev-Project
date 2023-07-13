import json,sys,re
from sqlalchemy.exc import SQLAlchemyError
from service.custom_exception import Error
from service.DBInit import DB
from models.get_flight import Flight

def lambda_handler(event, context):
    try:
        connection = DB()
        Session = connection.connect()
        session = Session()
        request_body = event["body-json"]
        if not request_body:
            raise ValueError("Validation error, Missing body")
        journey_id = request_body["journeyId"]
        flight_number = request_body["flightNumber"]
        flight_name = request_body["flightName"]
        journey_from = request_body["From"]
        journey_to = request_body["To"]
        date_of_journey = request_body["dateOfJourney"]
        depart_time = request_body["departureTime"]
        arrival_time = request_body["arrivalTime"]
        add_user = Flight()
        add_user.get_flight_request(request_body)
        session.add(add_user)
        session.commit()
        response = {
            "message":"Booking Details Added Successfully",
            "journey Id": journey_id,
            "Flight Number":flight_number,
            "Flight Name":flight_name,
            "Journey From":journey_from,
            "Journey To":journey_to,
            "Date of Journey":date_of_journey,
            "Departure Time":depart_time,
            "Arrival Time":arrival_time

        }
        return response

    except KeyError as error:
        error_response = {
            "error" : "Invalid request",
            "errorMessage" : str(error)
        }
        error_message = json.dumps(error_response)
        raise Error(error_message)

    except ValueError:
        error_response = {
            "error" : "Invalid request",
            "errorMessage" : "Missing / Wrong details"
        }
        error_message = json.dumps(error_response)
        raise Error(error_message)

    except SQLAlchemyError as error:
        response_post = {
            "error":"Invalid request",
            "errorMessage":str(error)
        }
        error_response = json.dumps(response_post)
        raise Error(error_response)

    except Exception as error:
        error_response = {
            "error" : "Internal server error",
            "errorMessage" : str(error)
        }
        error_message = json.dumps(error_response)
        raise Error(error_message)
        
    finally:
        session.close()