import os
import pandas as pd
import json
from utils import statxplore_to_json, JSONDIR
from statxplore import http_session
from statxplore import objects
from probe import session

# make some HBAI json files
filename ='HBAI_test.json'
database = 'str:database:HBAI'
measures = ['str:statfn:HBAI:V_F_HBAI:ABS1011BHC:MEDIAN']
dimensions = [['str:field:HBAI:V_F_HBAI:YEAR']]
statxplore_to_json(database, measures, dimensions, filename)
# path = 'pipelines/extract/json/HBAI_test.json'
# with open(path) as f:
#     query = json.load(f)
# string = json.dumps(query)
# #query = 'pipelines/extract/json/HBAI_test.json'
# data = objects.Table.query_json(session, string)
# print(data)
DATADIR = 'data/csv/HBAI/'
os.makedirs(DATADIR, exist_ok=True)
os.system("statxplore --api_key $STATXPLORE_API_KEY -q pipelines/extract/json/HBAI_test.json -o data/csv/HBAI/HBAI_test.csv")
