from sqlalchemy.ext.declarative import declarative_base
Base = declarative_base()
class BaseModel(Base):
    __abstract__ = True
    def to_dict(self):
        return {item.name: getattr(self, item.name) for item in self.__table__.columns}