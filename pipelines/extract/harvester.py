import statxplore
import os
from statxplore import http_session
from statxplore import objects

STATXPLORE_API_KEY = os.getenv("STATXPLORE_API_KEY")

session = http_session.StatSession(api_key=STATXPLORE_API_KEY)
# List all data schemas
schema = objects.Schema('str:database:HBAI').get(session)
#print(schema)
stuff = schema.get('children')
for i in stuff:
    print(i.get('id'))
    print(i.get('label'))
#print(objects.Table('str:database:UC_Monthly').run_query(session))