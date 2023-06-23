import pandas as pd
from utils import *
from describe import query_to_pandas

GEOLOOKUP = "data/geo/geography_lookup.csv"

if __name__ == '__main__':
    #get the data
    HBAI = query_to_pandas(STATXPLORE_API_KEY, 'pipelines/extract/json/data/HBAI.json')
    CLIF = query_to_pandas(STATXPLORE_API_KEY, 'pipelines/extract/json/data/CLIF.json')
    #slugify the column names
    HBAI.rename(columns=slugify, inplace=True)

    GEOLOOKUP_DF = pd.read_csv(GEOLOOKUP)

    name_to_code_dict = dict(list(zip(GEOLOOKUP_DF.LAD22NM, GEOLOOKUP_DF.LAD22CD)))
    
    CLIF.rename(columns=name_to_code_dict, inplace=True)
    #write to csv
    os.makedirs('data/hbai', exist_ok=True)
    os.makedirs('data/clif', exist_ok=True)
    HBAI.to_csv('data/hbai/hbai.csv')
    CLIF.to_csv('data/clif/clif.csv')