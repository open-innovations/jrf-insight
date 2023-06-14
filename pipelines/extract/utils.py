import os
import pandas as pd
import json
import re
from collections import OrderedDict
from statxplore import http_session
from statxplore import objects

STATXPLORE_API_KEY = os.getenv("STATXPLORE_API_KEY")
JSONDIR = 'pipelines/extract/json/'
session = http_session.StatSession(api_key=STATXPLORE_API_KEY)


def slugify(s):
    #TODO try replace '\W+'
    return re.sub(r'[\*\-\(\)\s\,\"\(/)]+', '_', s.lower())

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
        check = False
        id = str(i.get('id'))
        label = str(i.get('label'))
        if "str:measure:" in id or "str:count:" in id:
            
            measures.append(id)
            measure_names.append(label)
            continue
        elif "str:group" in id:
            # if database_id == 'str:database:HBAI':
            #     id = id[:-3]
            #     label = label[:-1]
            #print(id)
            check = True
            #print('group is', id)
            try:
                idss, labelss = group_to_fields(session, locator=id)

                # if there is >1 field, append each to a separate line of the csv
                # else append as normal (avoids breking each character to new line)
                if len(idss) > 1:
                    for iden, lab in zip(idss, labelss):
                        dimensions.append(iden)
                        dimension_names.append(lab)
                        #print('iden, lab = ', iden, lab)
                    # for lab in labelss:
                    #     dimension_names.append(lab)
                    #print('we appended several groups')
                else:
                    dimensions.append(idss[0])
                    dimension_names.append(labelss[0])
                    #print('idss, labels = ', idss[0], labelss[0])
                continue
            except:
                print(f'couldn\'t get groups for {id}')
                continue        
        elif check==False:
            #print('here')
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
        if not groups:
            print('couldnt get groups')
    except:
        print('failed to get groups for {}'.format(locator))
    return groups, group_labels

def statxplore_to_json(database, measures, dimensions, filename, DIR  ):
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
    os.makedirs(os.path.join(DIR), exist_ok=True)
    with open(os.path.join(DIR, '{}'.format(filename)), "w") as fp:
        json.dump(request, fp, indent=4, separators=(', ', ': ')) 
    return

def convert_to_dataframe(results, include_codes, reshape):
    """Convert the results returned from Stat-Xplore into a dataframe."""
    # First generate an ordered list of all the fields we will
    # be using, in human-readable format.
    field_names = [f["label"] for f in results["fields"]]

    # Next generate lists of all the values for each field, so that they
    # match up with the order of the data.
    field_labels = []
    for field in results["fields"]:
        field_labels.append([f["labels"][0] for f in field["items"]])
        
    if include_codes:
        # Certain fields include ONS codes in their URIs.  We should be
        # able to find these because ONS codes are always exactly 9
        # characters long and begin with a letter.
        field_codes = {}
        for field in results["fields"]:
            for item in field["items"]:
                if "uris" not in item:
                    # This field label doesn't have a URI associated with
                    # it (might be a Totals row), so ignore it.
                    continue
                code = item["uris"][0].rsplit(":", maxsplit=1)[1]
                if len(code) == 9 and code[0].isalpha():
                    if field["label"] not in field_codes:
                        field_codes[field["label"]] = {}
                    field_codes[field["label"]][item["labels"][0]] = code
        
    # Now go through all the measures and all the results in turn, saving
    # them off into a flat list.
    data = []
    for measure in results["measures"]:
        result_cube = results["cubes"][measure["uri"]]
        for field_row, value in zip(field_looper(field_names, 
                                                    field_labels), 
                                    value_looper(result_cube["values"])):
            output_row = OrderedDict()
            output_row.update(field_row)
            output_row.update({measure["label"]: value})
            data.append(output_row)
            
    data_pd = pd.DataFrame(data)

    if not reshape:
        # We haven't been asked to reshape the data appropriately, so just
        # return the raw dataframe.
        return data_pd

    # The shape of the dataframe we return is based on the number of
    # fields in the query.
    if len(field_names) == 1:
        # One field is effectively flat data, so just re-index on the 
        # field and return it.
        return data_pd.set_index(field_names[0])
    else:
        # Pivot the data to flatten it down to a 2D array.  We assume that
        # the first field in the query is the first dimension, the second
        # field is the second dimension, and all other fields should be
        # stacked under the first dimension to create multi-level rows.
        # All values get passed in at once - if there is more than one
        # this will create multi-level columns.
        indices = [field_names[0]]
        if len(field_names) > 2:
            indices.extend(field_names[2:])
        columns = [field_names[1]]
        
        # Extract the column labels in their original order, as the pivot
        # operation will sort them.
        column_labels = data_pd[field_names[1]].unique()
        
        values = [m["label"] for m in results["measures"]]
        if len(values) == 1:
            values = values[0]
        data_pd = pd.pivot_table(data_pd,
                                    values=values,
                                    index=indices,
                                    columns=columns)
        
        # Put the columns back in their original order.
        data_pd = data_pd[column_labels]
        
        if include_codes:
            for field_name, code_lookup in field_codes.items():
                if len(data_pd.index.names) == 1:
                    # Single-level index.  This means we can just do a
                    # lookup on the index values.
                    data_pd[field_name + " code"] = data_pd.index.map(
                        code_lookup)
                else:
                    # Multi-level index.  Find the field we're looking for
                    # in the indices.
                    field_ix = data_pd.index.names.index(field_name)
                    lookup = {}
                    for values in data_pd.index.values:
                        if values[field_ix] not in code_lookup:
                            # This is an index value without a code - 
                            # possibly a Totals row.  Skip it.
                            continue
                        lookup[values] = code_lookup[values[field_ix]]
                    data_pd[field_name + " code"] = data_pd.index.map(
                        lookup)
                data_pd = data_pd.set_index(field_name + " code", 
                                            append=True)
        
        return data_pd

# Recursive generators
def field_looper(field_names, field_labels):
    """Generator that returns each combination of fields in turn.  For each one
    it returns an ordered dict of field name: field label."""
    
    # We're going through these lists together, so they must be the same 
    # length.
    assert len(field_names) == len(field_labels)
    
    if len(field_names) == 1:
        # Looking at the bottom level.  Just loop through the labels.
        for label in field_labels[0]:
            yield OrderedDict({field_names[0]: label})
    else:
        # We're above the bottom level so we'll be calling ourselves again.
        # Loop over the first list of labels.
        for label in field_labels[0]:
            for lower_output in field_looper(field_names[1:], 
                                             field_labels[1:]):
                output = OrderedDict({field_names[0]: label})
                output.update(lower_output)
                yield output

        
def value_looper(array):
    """Generator that returns each element of a multi-dimensional array in
    turn, depth-first."""
    if isinstance(array[0], list):
        # There's another list inside this one - recurse again.
        for internal_array in array:
            for item in value_looper(internal_array):
                yield item
    else:
        # Not a list, so we're at the bottom.  Just yield each item in this
        # array.
        for item in array:
            yield item