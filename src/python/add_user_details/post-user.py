import json
from sqlalchemy.exc import SQLAlchemyError
from service.custom_exception import Error
from service.DBInit import DB
from models.login import Login

"""
 # @Python program 
 # @Author: Bhavya Sree
 # @Name: add-user-lambda.py
 # @Lambda name:lambda_post_user
 # @See: Program to add new user to login table 
"""
""" 
    Title:
        Lambda Handler method to insert/post  user data to the Database .
"""

def lambda_handler(event,context):
    try:
        connection = DB()
        Session = connection.connect()
        session = Session()
        request_body = event["body-json"]
        if not request_body:
            raise ValueError("Validation error, Missing body")
        email = request_body["email"]
        password = request_body["password"]
        is_admin = request_body["is_admin"]
        add_user = Login()
        add_user.login(request_body)
        session.add(add_user)
        session.commit()
        response = {
            "message":"User added successfully"
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












