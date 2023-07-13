#class for get flight mapping
class GetFligthMapping:
    GET_FLIGHT_MAPPING_TEMPLATE = {
        
        "journeyId": "journey_id",
        "flightNumber": "flight_num",
        "flightName": "flight_name",
        "dateOfJourney": "date",
        "From": "journey_from",
        "To": "journey_to",
        "departureTime": "departure_time",
        "arrivalTime": "arrival_time"

    }

#class for get book stock mapping
class GetBookingMapping:
    GET_BOOKING_MAPPING_TEMPLATE = {
        
        "bookingId": "booking_id",
        "journeyId": "journey_id"

    }

class AddUser:
    ADD_USER_TEMPLATE = {
        "email": "email",
        "password": "password",
        "is_admin": "is_admin"
    }