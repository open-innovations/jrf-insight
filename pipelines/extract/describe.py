import os
import pandas as pd
import json
import glob
from utils import statxplore_to_json, STATXPLORE_API_KEY, slugify
import statxplorer
from probe import session

def query_to_pandas(KEY, path_to_json):
    '''get the table and store the results as a dataframe'''
    explorer = statxplorer.StatXplorer(KEY)
    query_file = open(path_to_json)
    query = json.load(query_file)
    results = explorer.fetch_table(query)
    #print(results)
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
            return pd.DataFrame(), None
        #if we exhaust the list, break from the loop and return empty df
        i+=1
    
    #work out the frequency of the date
    #check year, quarter else assume its a month
    freq = ['month', 'year', 'quarter']
    for f in freq:
        #print(date_type_list[date_type_list.index(date_type_list[i-1])])
        if f in date_type_list[date_type_list.index(date_type_list[i-1])]:
            #print('here')
            dates_freq = f[0]
            break
        else:
            dates_freq = 'm'
            #break
    return dates.dimension, dates_freq

def metadata():
    '''
    Write a json containing the API call 
    to get the dates
    '''

    #list all the files to iterate through
    database_list = glob.glob('data/lookups/**/database.csv', recursive=True)
    dimension_list = glob.glob('data/lookups/**/dimension.csv', recursive=True)
    folder_list = glob.glob('data/lookups/*/*', recursive=True)
    for i, j, k in zip(database_list, dimension_list, folder_list):
        dataset = pd.read_csv(i)
        base = dataset['database']
        base_name = dataset['database_name']
        dimension = pd.read_csv(j)
        date_api_call, frequency = datetype_from_dimension(dimension)

        #print(f'API: {date_api_call}')
        if date_api_call.empty:
            print('No date fields')
            continue
        filename = f'{base_name.iloc[0]}.json'
        METADATA_DIR = 'pipelines/extract/json/metadata/'
        statxplore_to_json(database=base.iloc[0], dimensions=[[date_api_call.iloc[0]]], measures=[], filename=filename, DIR=METADATA_DIR)

        print(f'finished {base_name}')
        data = query_to_pandas(STATXPLORE_API_KEY, os.path.join(METADATA_DIR, filename))
        data.index.rename('dates_date', inplace=True)
        data.reset_index(inplace=True)
        frame = pd.DataFrame(data={'dates_date': data.dates_date}).set_index('dates_date')
        frame['freq'] = frequency
        frame.to_csv(os.path.join(k, 'metadata.csv'))
    return

def dates_to_csv(key, PATH):
    data = query_to_pandas(key, PATH)
    data.index.rename('dates_date', inplace=True)
    data.reset_index(inplace=True)

    return data.dates_date

if __name__ == '__main__':
    metadata()
    