import pandas as pd
import geopandas as gpd
from params import DATA_DIR


def load_geojson(type):
    '''
    Load data of type and return a `GeoDataFrame`
    '''
    path = f'{DATA_DIR}/geo/{type}.geojson'
    key = type.upper() + 'CD'
    data = gpd.read_file(path)
    if type == 'panrgn22':
        key = 'RGN21CD'
        data.loc[data.RGN21NM == 'The North', 'RGN21CD'] = 'E12999901'
    if type == 'cty22_ua22':
        key = 'CTYUA22CD'
    data.index = pd.Index(data[key], name='ons_code')
    data['ons_code'] = data.index.to_series()
    data['ons_type'] = key
    return data
