import os
import pandas as pd
from statxplore import http_session
from statxplore import objects

STATXPLORE_API_KEY = os.getenv("STATXPLORE_API_KEY")
session = http_session.StatSession(api_key=STATXPLORE_API_KEY)

# Get a list of all folders on StatXplore
folders = objects.Schema.list(session)
folder_children = folders.get('children')
folder_ids = []
folder_names = []
for child in folder_children:
    folder_ids.append(str(child.get('id')))
    folder_names.append(str(child.get('label')))

database_ids = []
database_names = []
for id in folder_ids:
    databases = objects.Schema(id).get(session)
    database_ids.append(databases.get('id'))
    database_names.append(databases.get('label'))
#print(database_names)

#for database in database_names
schema = objects.Schema('str:database:HBAI').get(session)
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
#print(measure_names[0])
#print(children)

measures_df = pd.DataFrame([[i, j] for i, j in zip(measures, measure_names)], columns=['measure', 'measure_name']).set_index('measure_name')
dimensions_df = pd.DataFrame([[i, j] for i, j in zip(dimensions, dimension_names)], columns=['dimension', 'dimension_name']).set_index('dimension_name')

OUTDIR = 'data/csv/hbai/hbai/'
os.makedirs(OUTDIR, exist_ok=True)

dimensions_df.to_csv(os.path.join(OUTDIR, 'dimensions.csv'))
measures_df.to_csv(os.path.join(OUTDIR, 'measures.csv'))
# test_table = objects.Table('str:database:HBAI').run_query(session,
#     measures=[measures[0]],
#     dimensions=[[dimensions[0]]],
# )
