import os
import pandas as pd
import json
import glob
from utils import statxplore_to_json, JSONDIR, convert_to_dataframe, slugify, STATXPLORE_API_KEY
from statxplore import http_session
from statxplore import objects
import statxplorer
from probe import session

# make some HBAI json files
# filename ='HBAI_test.json'
# database = 'str:database:HBAI'
# measures = []
# dimensions = [['str:field:HBAI:V_F_HBAI:YEAR']]

#make the json query file
#statxplore_to_json(database, measures, dimensions, filename, DIR=JSONDIR)

path_to_json = 'pipelines/extract/json/HBAI_test.json'

#get the table and store the results as a dataframe
def query_to_pandas(KEY, path_to_json):
    explorer = statxplorer.StatXplorer(KEY)
    query_file = open(path_to_json)
    query = json.load(query_file)
    results = explorer.fetch_table(query)
    return results['data']

DATADIR = 'data/csv/HBAI/'
os.makedirs(DATADIR, exist_ok=True)


# data.reset_index(inplace=True)
# data.rename(columns=slugify, inplace=True)
# date_type_list = ['month', 'quarter', 'year', 'financial_year']
# print(data.columns.to_list())
def datetype_from_dimension(dataframe):
    date_type_list = ['Month', 'Quarter', 'Year', 'Financial Year', 'Month of Off Flow', 'Onflow Month', 'Off-flow Month']
    for type in date_type_list:
        try:
            dates = dataframe[dataframe['dimension_name'] == type]
            return dates.dimension
        except:
            print('None of the date types were available.')
            
#dates.to_csv(os.path.join())

# def dates_from_dataset(api_result):
#     data = convert_to_dataframe(api_result, reshape=False, include_codes=False)
#     data.rename(columns=slugify, inplace=True)
#     years = data['financial_year']
#     months = data['month']

def dates_from_database():
    '''
    Write a csv containing the dates assocated
    with each database.
    '''
    database_list = glob.glob('data/lookups/**/database.csv', recursive=True)
    dimension_list = glob.glob('data/lookups/**/dimension.csv', recursive=True)
    for i, j in zip(database_list, dimension_list):
        set = pd.read_csv(i)
        base = set['database']
        base_name = set['database_name']
        dimension = pd.read_csv(j).reset_index()
        date_api_call = datetype_from_dimension(dimension)
        print('database api call {}'.format(base.iloc[0]))
        print('date_api_call {}'.format(date_api_call.iloc[0]))
        statxplore_to_json(database=base.iloc[0], dimensions=[[date_api_call.iloc[0]]], measures=[], filename='{}.json'.format(base_name.iloc[0]), DIR='pipelines/extract/json/metadata/')
        print(f'finished {base_name}')
    # database = pd.read_csv(os.path.join(dirnames, 'database.csv'))
    # dimension = pd.read_csv(os.path.join(dirpath, 'dimension.csv'))
    # #some code to extract the date dimension
    # db_api_call = database['database'].value
    # #dim_api_call = dimension['']
    # print(db_api_call)
    # print(dim_api_call)
    # statxplore_to_json(database, measures, dimensions, filename)
    # data = query_to_pandas(STATXPLORE_API_KEY, )


    return

dates_from_database()