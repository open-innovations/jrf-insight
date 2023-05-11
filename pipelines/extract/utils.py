import os
import pandas as pd
from statxplore import http_session
from statxplore import objects


def get_ids(session, locator=None):
    '''
    Gets IDs and Labels from the statXplore
    API schema. 
    
    If locator is None, a list of folder ids
    and names will be returned.
     
    If locator is specified it will
    target low levels of the statXplore database 
    i.e. individual folders.
    '''
    if locator == None:
        schema = objects.Schema.list(session)
    else:
        schema = objects.Schema(locator).get(session)
    
    children = schema.get('children')

    ids = []
    labels = []

    for i in children:
        ids.append(str(i.get('id')))
        labels.append(str(i.get('label')))
    
    return ids, labels

def get_variables(session, database_id, database_name):
    '''
    Get the measures and dimensions from individual tables
    Both the human readable names and the API calls.
    '''
    schema = objects.Schema(database_id).get(session)
    children = schema.get('children')

    measures = []
    measure_names = []
    dimensions = []
    dimension_names = []

    for i in children:

        id = str(i.get('id'))
        label = str(i.get('label'))

        if "str:measure:" in id or "str:count:" in id:
            measures.append(id)
            measure_names.append(label)
            continue
        
        dimensions.append(id)
        dimension_names.append(label)

def make_csv(ids, labels, f_name, db_name):
    '''
    Makes csv files 
    '''
    i_str = str(ids)
    l_str = str(labels)
    df = pd.DataFrame([[i, j] for i, j in zip(ids, labels)], columns=[i_str, l_str]).set_index(l_str)

    OUTDIR = 'data/csv/{folder}/{database}/'.format(folder=f_name, database=db_name)
    os.makedirs(OUTDIR, exist_ok=True)

    df.to_csv(os.path.join(OUTDIR, '{}.csv'.format(i_str)))

    return