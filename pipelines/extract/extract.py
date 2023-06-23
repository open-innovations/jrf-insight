import pandas as pd
from utils import *
from describe import query_to_pandas

if __name__ == '__main__':
    #get the data
    HBAI = query_to_pandas(STATXPLORE_API_KEY, 'pipelines/extract/json/data/HBAI.json')
    CLIF = query_to_pandas(STATXPLORE_API_KEY, 'pipelines/extract/json/data/CLIF.json')
    #slugify the column names
    HBAI.rename(columns=slugify, inplace=True)
    CLIF.rename(columns=slugify, inplace=True)
    #write to csv
    os.makedirs('data/hbai', exist_ok=True)
    os.makedirs('data/clif', exist_ok=True)
    HBAI.to_csv('data/hbai/hbai.csv')
    CLIF.to_csv('data/clif/clif.csv')