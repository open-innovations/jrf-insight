import pandas as pd
from utils import *
from describe import query_to_pandas
import json

GEOLOOKUP = "data/geo/geography_lookup.csv"
HBAI_JSON = 'pipelines/extract/json/data/HBAI.json'
if __name__ == '__main__':
    dates = ['1011', '1112', '1213', '1314', '1415', '1516', '1617', '1718', '1819', '1920', '2021', '2122']
    os.makedirs('data/hbai', exist_ok=True)
    for date in dates:
        with open(HBAI_JSON, 'r') as json_file:
            data  = json.load(json_file)
        
        data['recodes']['str:field:HBAI:V_F_HBAI:YEAR']['map'] = [[f'str:value:HBAI:V_F_HBAI:YEAR:C_HBAI_YEAR:{date}']]
    
        with open(HBAI_JSON, "w") as jsonFile:
            data = json.dump(data, jsonFile)

        HBAI = query_to_pandas(STATXPLORE_API_KEY, 'pipelines/extract/json/data/HBAI.json')
        HBAI.rename(columns=slugify, inplace=True)
        HBAI.to_csv(f'data/hbai/hbai_{date}.csv')
    
    #get the data
    CLIF = query_to_pandas(STATXPLORE_API_KEY, 'pipelines/extract/json/data/CLIF.json').reset_index()
    #slugify the column names

    GEOLOOKUP_DF = pd.read_csv(GEOLOOKUP)
    
    name_to_code_dict = dict(list(zip(GEOLOOKUP_DF.LAD22NM, GEOLOOKUP_DF.LAD22CD)))
    CLIF.rename(columns=name_to_code_dict, inplace=True, errors="raise")    

    #@TODO rewrite below so its not hard-coded.
    CLIF_long = pd.melt(CLIF, id_vars=['Year', 'Age of Child (years and bands)', 'Gender of Child', 'Family Type', 'Work Status'], value_vars=CLIF.columns.to_list()[5:], var_name='geography_code').set_index('Year')

    #write to csv
    os.makedirs('data/clif', exist_ok=True)
    CLIF_long.to_csv('data/clif/clif.csv')