import os
import pandas as pd
from statxplore import http_session
from statxplore import objects
from utils import get_ids, get_variables, make_csv, session, STATXPLORE_API_KEY

folder_ids, folder_names = get_ids(session)

for folder_id, folder_name in zip(folder_ids, folder_names):
    database_ids, database_names = get_ids(session, locator=folder_id)

    for database_id, database_name in zip(database_ids, database_names):
        measures, measure_names, dimensions, \
            dimension_names = get_variables(session, database_id)
        
        print('Got lookups for database {} in folder {}'.format(database_name, folder_name))

        OUTDIR = 'data/lookups/{folder}/{database}/'.format(folder=folder_name, database=database_name)
        os.makedirs(OUTDIR, exist_ok=True)

        make_csv(measures, measure_names, OUTDIR, type='measure')
        make_csv(dimensions, dimension_names, OUTDIR, type='dimension')
        make_csv(database_id, database_name, OUTDIR, type='database')
        