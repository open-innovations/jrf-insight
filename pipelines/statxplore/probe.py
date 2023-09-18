import logging
import os

import pandas as pd
from statxplore import http_session
from utils import get_ids, get_variables, sanitize_filepart

from api import STATXPLORE_API_KEY

logging.basicConfig(level=logging.INFO, encoding="utf-8")

session = http_session.StatSession(api_key=STATXPLORE_API_KEY)

def make_csv(ids, labels, OUTDIR, type=None):
    '''
    Makes csv files 
    '''
    
    # if a database, there is only id and label, 
    # so iterating would write each character to a new line.

    if type == 'database':
        df = pd.DataFrame(
            [[ids, labels]], columns=[f'{type}', f'{type}_name']
        ).set_index(f'{type}_name')
    else:
        df = pd.DataFrame(
            [[i, j] for i, j in zip(ids, labels)],
            columns=[f'{type}', f'{type}_name'],
        ).set_index(f'{type}_name')

    df.to_csv(os.path.join(OUTDIR, f'{type}.csv'))

    return


if __name__ == '__main__':

    folder_ids, folder_names = get_ids(session)
    for folder_id, folder_name in zip(folder_ids, folder_names):
        database_ids, database_names = get_ids(session, locator=folder_id)

        for database_id, database_name in zip(database_ids, database_names):
            measures, measure_names, dimensions, \
                dimension_names = get_variables(session, database_id)
            
            logging.info('Got lookups for database "%s" in folder %s', database_name, folder_name)

            OUTDIR = f'data/lookups/{sanitize_filepart(folder_name)}/{sanitize_filepart(database_name)}/'
            os.makedirs(OUTDIR, exist_ok=True)

            make_csv(measures, measure_names, OUTDIR, type='measure')
            make_csv(dimensions, dimension_names, OUTDIR, type='dimension')
            make_csv(database_id, database_name, OUTDIR, type='database')
            