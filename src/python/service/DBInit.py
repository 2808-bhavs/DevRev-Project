from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
import os


class DB:
    """
    This class is used to connect the databse to the lambda function by retrieving the details from environment variables
    """
    def __init__(self):
        self.user = os.environ['user']
        self.password = os.environ['password']
        self.host = os.environ['host']
        self.port = os.environ['port']
        self.database = os.environ['database']
        self.connect_timeout = os.environ['timeout']
        self.schema = os.environ['schema']

    def connect(self):
        """
        This method connects the databse with the lambda function
        """

        db_string = "postgresql://{}:{}@{}:{}/{}".format(
            self.user,
            self.password,
            self.host,
            self.port,
            self.database
        )

        db = create_engine(
            db_string,
            connect_args={
                'connect_timeout': self.connect_timeout,
                'options': '-csearch_path={}'.format(self.schema)
            },
            hide_parameters=True
        )

        Session = sessionmaker(bind=db)
        return Session