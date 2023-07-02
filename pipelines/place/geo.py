import pandas as pd
import numpy as np

from params import DATA_DIR

geo_tree = pd.read_csv(f'{DATA_DIR}/geo/geography_tree.csv')


def get_all_codes():
    return np.unique((geo_tree)[['parent', 'child']].to_numpy().flatten()).tolist()


def flatten(list_of_lists):
    return [item for list in list_of_lists for item in list]


def all_codes():
    return geo_tree.parent.drop_duplicates().to_list()


def get_parents(code):
    return geo_tree[geo_tree.child == code].parent.to_list()


def get_children(code):
    return geo_tree[geo_tree.parent == code].child.to_list()


def get_descendents(*codes):
    children = flatten([get_children(code) for code in codes])
    if (len(children) == 0):
        return []
    return children + get_descendents(*children)


def get_lookup():
    geo = pd.read_csv(f'{DATA_DIR}/geo/geography_lookup.csv')
    codes = geo.columns[geo.columns.str.endswith('CD')]
    names = geo.columns[geo.columns.str.endswith('NM')]

    def make_lookup(pair):
        pair = pd.Index(pair)
        type = pair[0][:-2]
        frame = geo.loc[:, pair].drop_duplicates().rename(
            columns=lambda c: c[-2:])
        frame['type'] = type
        return frame
    geo_lookup = pd.concat([make_lookup(pair) for pair in zip(
        codes.to_list(), names.to_list())]).dropna()
    geo_lookup.columns = ['code', 'name', 'type']
    geo_lookup = geo_lookup.set_index('code')
    return geo_lookup


def patch_missing_arrays(data, column_name):
    na_pos = data[column_name].isna()
    data[column_name][na_pos] = data[column_name][na_pos].apply(lambda x: [])
    return data


def get_place_data():
    place_data: list = []

    for code in get_all_codes():
        direct_parents = get_parents(code)
        direct_children = get_children(code)
        all_children = get_descendents(code)
        place_data.append({
            'key': code,
            'children': all_children,
            'direct_parents': direct_parents,
            'direct_children': direct_children,
        })
    place_data = pd.DataFrame(place_data).set_index('key').merge(
        right=get_lookup(), left_index=True, right_index=True, how='outer')

    place_data = place_data.pipe(patch_missing_arrays, 'children').pipe(
        patch_missing_arrays, 'direct_children').pipe(patch_missing_arrays, 'direct_parents')
    return place_data
