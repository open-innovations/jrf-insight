import os
import pandas as pd
from statxplore import http_session
from statxplore import objects

STATXPLORE_API_KEY = os.getenv("STATXPLORE_API_KEY")
session = http_session.StatSession(api_key=STATXPLORE_API_KEY)

# Get a list of all folders on StatXplore
folders = objects.Schema.list(session)
children = folders.get('children')
folder_ids = []
folder_names = []
for child in children:
    folder_ids.append(str(child.get('id')))
    folder_names.append(str(child.get('label')))

for f_id, f_name in zip(folder_ids, folder_names):
    databases = objects.Schema(f_id).get(session)
    children = databases.get('children')
    database_ids = []
    database_names = []
    for child in children:
        database_names.append(child.get('label'))
        database_ids.append(child.get('id'))
    #print(f_name, database_names)
    #print(database_names)
    for db_id, db_name in zip(database_ids, database_names):
        #print(folder_names[count], db_name)
        schema = objects.Schema(db_id).get(session)
        #print(schema)
        children = schema.get('children')
        measures = []
        measure_names = []
        dimensions = []
        dimension_names = []

        for i in children:

            id = str(i.get('id'))
            label = str(i.get('label'))

            if "measure" in id:
                measures.append(id)
                measure_names.append(label)
            else:
                dimensions.append(id)
                dimension_names.append(label)

        measures_df = pd.DataFrame([[i, j] for i, j in zip(measures, measure_names)], columns=['measure', 'measure_name']).set_index('measure_name')
        dimensions_df = pd.DataFrame([[l, m] for l, m in zip(dimensions, dimension_names)], columns=['dimension', 'dimension_name']).set_index('dimension_name')

        OUTDIR = 'data/csv/{folder}/{database}/'.format(folder=f_name, database=db_name)
        os.makedirs(OUTDIR, exist_ok=True)

        dimensions_df.to_csv(os.path.join(OUTDIR, 'dimensions.csv'))
        measures_df.to_csv(os.path.join(OUTDIR, 'measures.csv'))
# test_table = objects.Table('str:database:HBAI').run_query(session,
#     measures=[measures[0]],
#     dimensions=[[dimensions[0]]],
# )
