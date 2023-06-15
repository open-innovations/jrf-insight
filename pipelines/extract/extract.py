import os
import pandas as pd
import json
import glob
from utils import statxplore_to_json, JSONDIR, STATXPLORE_API_KEY
from statxplore import http_session
from statxplore import objects
import statxplorer
from probe import session

#statxplore_to_json(database, measures, dimensions, filename, DIR=JSONDIR)


def query_to_pandas(KEY, path_to_json):
    '''get the table and store the results as a dataframe'''
    explorer = statxplorer.StatXplorer(KEY)
    query_file = open(path_to_json)
    query = json.load(query_file)
    results = explorer.fetch_table(query)
    return results['data']

def datetype_from_dimension(df):
    '''Get the date field and its API call'''
    date_type_list = ['month', 'quarter', 'year', 'financial_year',
                      'month_of_off_flow', 'month_of_on_flow', 'onflow_month', 
                      'off-flow_month', 'date', 'claim_start_date', 'completed_assessment_date',
                      'date_of_decision', 'date_of_dwp_decision', 'date_of_registration',
                      'quarter_and_year_of_registration', 'month_decision_made',
                      'time_period', 'decision_month', 'start_month', 'referral_month']
    #slugify
    df['dimension_name'] = df['dimension_name'].str.replace(r'\W+', '_', regex=True)
    df['dimension_name'] = df['dimension_name'].str.lower()
    
    
    dates = df[df['dimension_name'].str.fullmatch(date_type_list[0])]

    i = 0
    #print(len(date_type_list))
    while dates.empty:
        #iterate through the list of date types
        try:
            dates = df[df['dimension_name'].str.fullmatch(date_type_list[i])]
        except:
            print('No date fields')
            return pd.DataFrame()
        #if we exhaust the list, break from the loop and return empty df
        i+=1
        
    return dates.dimension

def dates_from_database():
    '''
    Write a csv containing the dates assocated
    with each database.
    '''

    #list all the files to iterate through
    database_list = glob.glob('data/lookups/**/database.csv', recursive=True)
    dimension_list = glob.glob('data/lookups/**/dimension.csv', recursive=True)

    for i, j in zip(database_list, dimension_list):
        set = pd.read_csv(i)
        base = set['database']
        base_name = set['database_name']
        dimension = pd.read_csv(j)

        date_api_call = datetype_from_dimension(dimension)
        print(f'API: {date_api_call}')
        if date_api_call.empty:
            print('No date fields')
            continue

        statxplore_to_json(database=base.iloc[0], dimensions=[[date_api_call.iloc[0]]], measures=[], filename='{}.json'.format(base_name.iloc[0]), DIR='pipelines/extract/json/metadata/')

        print(f'finished {base_name}')

        # data = query_to_pandas(STATXPLORE_API_KEY, )

        # @TODO
        #1 query the API witht the jsons
        #2 extract the dates
        #3 write them to csv in 'data/lookups/<database>/dates.csv

    return
if __name__ == '__main__':
    dates_from_database()