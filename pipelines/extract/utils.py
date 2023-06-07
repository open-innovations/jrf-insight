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
    #print(schema)    
    children = schema.get('children')

    ids = []
    labels = []

    for i in children:
        ids.append(str(i.get('id')))
        labels.append(str(i.get('label')))
    
    return ids, labels

def get_variables(session, database_id):
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
    #print(children)
    for i in children:

        id = str(i.get('id'))
        label = str(i.get('label'))

        if "str:measure:" in id or "str:count:" in id:
            measures.append(id)
            measure_names.append(label)
            continue
        
        dimensions.append(id)
        dimension_names.append(label)
        
    return measures, measure_names, dimensions, dimension_names

def make_csv(ids, labels, OUTDIR, type=None):
    '''
    Makes csv files 
    '''
    if type == 'database':
        df = pd.DataFrame([[ids, labels]], columns=['{}'.format(type), '{}_name'.format(type)]).set_index('{}_name'.format(type))
    else:
        df = pd.DataFrame([[i, j] for i, j in zip(ids, labels)], columns=['{}'.format(type), '{}_name'.format(type)]).set_index('{}_name'.format(type))

    df.to_csv(os.path.join(OUTDIR, '{}.csv'.format(type)))

    return

def group_to_field(session):
    root_folder = "/data/lookups/"
    print(root_folder)
    for dirpath, dirnames, filenames in os.walk(root_folder):
        if "dimension.csv" in dirnames:
            dimension_folder_path = os.path.join(dirpath, "dimension.csv")
            df = pd.read_csv(dimension_folder_path)
            print(df)
            if df.str.contains('str:group:'):
                groups, group_labels = get_ids(session, locator=id)
                print(groups, group_labels)
                #measures.append(groups)
                #measure_names.append(group_labels)
    return