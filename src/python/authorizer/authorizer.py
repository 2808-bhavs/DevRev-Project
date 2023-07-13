from service.DBInit import DB
from models.users import Login

"""
 # @Python program 
 # @Author: Bhavya Sree
 # @Name: authorizer.py
 # @Lambda name: api_gateway_authorizer_ftb
 # @Version: 1.0
 # @See: Program to validate the user
"""


def lambda_handler(event,context):

    """ 
    Title:
        Lambda Handler method to authenticate the user based on the email and password provided

    Arguments :
        event(Dict) : It consists email and password which are need to be validated

    Returns: 
            It returns a JSON which decides to allow/deny the user for performing particular actions.
    """
    connection = DB()
    Session = connection.connect()
    session = Session()
    email = event['headers']['email']
    password = event['headers']['password']
    method_arn = event['methodArn']
    effect = "Deny"
    result = session.query(Login).filter((Login.email == email),(Login.password == password))
    for user in result:
        if user.is_admin == True:
            effect = "Allow"
            break
        else:
            if "GET" in method_arn:
                effect = "Allow"
                break
            else:
                effect = "Deny"
                raise Exception("Unauthorized")
    else:
        effect = 'Deny'
        raise Exception("Unauthorized")
    return {
       "principalId" : "principalId",
       "policyDocument" : {
                "Version" : "2012-10-17",
                "Statement" : [
                    {
                        "Action" : "execute-api:Invoke",
                        "Effect" : effect,
                        "Resource" : method_arn
                    }
                ]
            }
        }
