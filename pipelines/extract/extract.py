import os
import pandas as pd
import json
from utils import statxplore_to_json, JSONDIR, convert_to_dataframe, slugify, STATXPLORE_API_KEY
from statxplore import http_session
from statxplore import objects
import statxplorer
from probe import session

# make some HBAI json files
filename ='HBAI_test.json'
database = 'str:database:HBAI'
measures = []
dimensions = [['str:field:HBAI:V_F_HBAI:YEAR']]

#make the json query file
statxplore_to_json(database, measures, dimensions, filename)

path_to_json = 'pipelines/extract/json/HBAI_test.json'

#get the table and store the results as a dataframe
explorer = statxplorer.StatXplorer(STATXPLORE_API_KEY)
query_file = open(path_to_json)
query = json.load(query_file)
results = explorer.fetch_table(query)
data = results['data']

DATADIR = 'data/csv/HBAI/'
os.makedirs(DATADIR, exist_ok=True)


data.reset_index(inplace=True)
data.rename(columns=slugify, inplace=True)
date_type_list = ['month', 'quarter', 'year', 'financial_year']
print(data.columns.to_list())
for type in date_type_list:
    try:
        years = data[type]
    except:
        print('None of the date types were available.')
print(years)

# def dates_from_dataset(api_result):
#     data = convert_to_dataframe(api_result, reshape=False, include_codes=False)
#     data.rename(columns=slugify, inplace=True)
#     years = data['financial_year']
#     months = data['month']

