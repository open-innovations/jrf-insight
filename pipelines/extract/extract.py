import pandas as pd
from utils import *
from describe import query_to_pandas

GEOLOOKUP = "data/geo/geography_lookup.csv"

if __name__ == '__main__':
    #get the data
    HBAI = query_to_pandas(STATXPLORE_API_KEY, 'pipelines/extract/json/data/HBAI.json')
    CLIF = query_to_pandas(STATXPLORE_API_KEY, 'pipelines/extract/json/data/CLIF.json').reset_index()
    #slugify the column names
    HBAI.rename(columns=slugify, inplace=True)

    GEOLOOKUP_DF = pd.read_csv(GEOLOOKUP)
    #geo_test = GEOLOOKUP_DF[[GEOLOOKUP_DF['RGN22NM'] == 'North East'] or [GEOLOOKUP_DF['RGN22NM'] == 'North West'] or [GEOLOOKUP_DF['RGN22NM'] == 'Yorkshire and The Humber']]
    #print(geo_test.LAD22NM)
    name_to_code_dict = dict(list(zip(GEOLOOKUP_DF.LAD22NM, GEOLOOKUP_DF.LAD22CD)))
    CLIF.rename(columns=name_to_code_dict, inplace=True, errors="raise")    

    #@TODO rewrite below so its not hard-coded.
    CLIF_long = pd.melt(CLIF, id_vars=['Year', 'Age of Child (years and bands)', 'Gender of Child', 'Family Type', 'Work Status'], value_vars=CLIF.columns.to_list()[5:], var_name='geography_code').set_index('Year')

    #write to csv
    os.makedirs('data/hbai', exist_ok=True)
    os.makedirs('data/clif', exist_ok=True)
    HBAI.to_csv('data/hbai/hbai.csv')
    CLIF_long.to_csv('data/clif/clif.csv')