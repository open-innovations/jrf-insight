import os
import pandas as pd
import json
from statxplore import http_session
from statxplore import objects

STATXPLORE_API_KEY = os.getenv("STATXPLORE_API_KEY")
JSONDIR = 'pipelines/extract/json/'
session = http_session.StatSession(api_key=STATXPLORE_API_KEY)


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
    # print(schema)
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
    # print(children)
    for i in children:

        id = str(i.get('id'))
        label = str(i.get('label'))
        if "statfn" in id:
            print('there was a statfn')
        if "str:measure:" in id or "str:count:" in id or "str:statfn:" in id:
            
            measures.append(id)
            measure_names.append(label)
            continue
        elif "str:group" in id:
            for id, label in group_to_fields(session, locator=id):
                
                # if there is >1 field, append each to a separate line of the csv
                # else append as normal (avoids breking each character to new line)
                if len(id) > 1:
                    for iden in id:
                        dimensions.append(iden)
                    for lab in label:
                        dimension_names.append(lab)
                else:
                    dimensions.append(id)
                    dimensions.append(label)
            continue
        dimensions.append(id)
        dimension_names.append(label)

    return measures, measure_names, dimensions, dimension_names


def make_csv(ids, labels, OUTDIR, type=None):
    '''
    Makes csv files 
    '''
    if type == 'database':
        df = pd.DataFrame([[ids, labels]], columns=['{}'.format(
            type), '{}_name'.format(type)]).set_index('{}_name'.format(type))
    else:
        df = pd.DataFrame([[i, j] for i, j in zip(ids, labels)], columns=[
                          '{}'.format(type), '{}_name'.format(type)]).set_index('{}_name'.format(type))

    df.to_csv(os.path.join(OUTDIR, '{}.csv'.format(type)))

    return


def group_to_fields(session, locator):
    '''
    Take the 'group' names and return the field
    labels and ids contained within. 
    '''
    try:
        groups, group_labels = get_ids(session, locator=locator)
        yield groups, group_labels
    except:
        print('failed to get groups for{}'.format(locator))


def statxplore_to_json(database, measures, dimensions, filename):
    '''
    Makes a json for the API call to statXplore.

    Inputs
    ------
    database : str
        a string with the database name
    measures : list
        list containing the measures (str) (can provide 1 but must be in a list)
    dimensions: list
        a list of lists, inside which is a string with the dimension name
    filename: str
        name of the json file
    Returns
    -------
    A json stored in filename
    '''
    #assert len(database) == 1, "Please ensure only 1 database is provided"
    request = {
        "database": database,
        "measures": measures,
        "dimensions": dimensions
    }
    with open(os.path.join(JSONDIR, '{}'.format(filename)), "w") as fp:
        json.dump(request, fp, indent=4, separators=(', ', ': ')) 

