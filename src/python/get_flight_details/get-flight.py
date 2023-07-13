import json
from service.DBInit import DB
from models.get_flight import Flight
from service.custom_exception import Error
from uuid import UUID
from sqlalchemy.exc import NoResultFound
from datetime import datetime

"""
 # @Python program 
 # @Author: Bhavya Sree
 # @Name: get-flight.py
 # @Lambda name: lambda_get_flight
 # @Since: December 2022
 # @Version: 1.0
 # @See: Program to get flight details from DB
"""
""" 
    Title:
        Lambda Handler method just gets the flight details from db.
"""

def lambda_handler(event,context):
    try:
    #return event
        connection = DB()
        Session = connection.connect()
        session = Session()
        journey_from = event['params']['querystring']['from']
        journey_to = event['params']['querystring']['to']
        journey_date = event['params']['querystring']['date']
        time_from = event['params']['querystring']['time_from']
        time_to = event['params']['querystring']['time_to']
        time_from = datetime.strptime(time_from, '%H:%M:%S')
        time_to = datetime.strptime(time_to, '%H:%M:%S')

        flight_data = session.query(Flight).filter(Flight.journey_from == journey_from, Flight.journey_to == journey_to, Flight.date == journey_date).all()
        response_list = []
        flight_list=[]
        for data in flight_data:
            response = {
                "flightNumber": str(data.flight_num),
                "flightName": str(data.flight_name),
                "dateOfJourney": str(data.date),
                "From": str(data.journey_from),
                "To": str(data.journey_to),
                "departureTime": data.departure_time,
                "arrivalTime": str(data.arrival_time)[11:16]
                }
            response_list.append(response)
        for data in response_list:
            check_time = data.get('departureTime')
            if check_time.time() >= time_from.time() and check_time.time() <= time_to.time():
                data['departureTime'] = str(check_time)[11:16]
                flight_list.append(data)
        if not response_list:
            raise NoResultFound('flight not found')
        return flight_list
    except NoResultFound:
        error_response = {
            "message" : "flight not found"
        }
        error = json.dumps(error_response)
        raise Error(error)
        
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

    except Exception as error:
        error_response = {
            "error" : "Internal server error",
            "errorMessage" : str(error)
        }
        error_message = json.dumps(error_response)
        raise Error(error_message)

    finally:
        session.close()
    