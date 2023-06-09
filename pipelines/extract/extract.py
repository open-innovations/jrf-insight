import pandas as pd
from utils import *
from describe import query_to_pandas
import json

GEOLOOKUP = "data/geo/geography_lookup.csv"
HBAI_JSON = 'pipelines/extract/json/data/HBAI.json'
CLIF_JSONS = ['pipelines/extract/json/data/CLIF_REL.json', 'pipelines/extract/json/data/CLIF_ABS.json']
#dates = ['1011', '1112', '1213', '1314', '1415', '1516', '1617', '1718', '1819', '1920', '2021', '2122']

def houses_below_avg_income():
    """
        Harvest the data for children 
        in low income families from
        statXplore.
    """
    dimensions = [ 
        ["str:field:HBAI:V_F_HBAI:TYPE_AGECAT"], 
        ["str:field:HBAI:V_F_HBAI:NUMBKIDS"], 
        ["str:field:HBAI:V_F_HBAI:YOUNGCH"], 
        ["str:field:HBAI:V_F_HBAI:TENHBAI"], 
        ["str:field:HBAI:V_F_HBAI:CAPITAL"], 
        ["str:field:HBAI:V_F_HBAI:ETHGRPHHPUB"]
                  ]
    dimension_names = [ 
        "Type of Individual by Age Category", 
        "Number of Children in the Family of the Individual", 
        "Age of the Youngest Child in the Family of the Individual", 
        "Tenure Type of the Household of the Individual", 
        "Savings and Investments of Adults in the Family of the Individual", 
        "Ethnic Group of the Head of the Household (please calculate three-year averages - click on i for the correct method)"
                  ]
    location = 'Location in the United Kingdom of the Household of the Individual (please calculate three-year averages - click on i for the correct method)'
    for dim, name in zip(dimensions, dimension_names):
        os.makedirs(f'data/hbai/', exist_ok=True)
        with open(HBAI_JSON, 'r') as json_file:
            data  = json.load(json_file)
        
        data['dimensions'] = [["str:field:HBAI:V_F_HBAI:YEAR"], ["str:field:HBAI:V_F_HBAI:LOW60BHC"], 
                            ["str:field:HBAI:V_F_HBAI:GVTREGN_LON"], dim]
        
        with open(HBAI_JSON, "w") as jsonFile:
            data = json.dump(data, jsonFile)
        
        HBAI = query_to_pandas(STATXPLORE_API_KEY, 'pipelines/extract/json/data/HBAI.json').reset_index()
        HBAI[['geography_name', 'geography_code']] = HBAI[location].str.split('(', expand=True)
        HBAI['geography_code'] = HBAI['geography_code'].str.replace(')', '')
        HBAI['geography_name'] = HBAI['geography_name'].str.strip()
        HBAI.drop(location, axis=1, inplace=True)
        HBAI = pd.melt(HBAI, id_vars=['Financial Year', 'geography_name', 'geography_code', f'{name}'],
                                      var_name='variable_name')
        HBAI.set_index('Financial Year', inplace=True)
        HBAI['variable_name'] = HBAI['variable_name'].str.replace(' (at or above threshold)', '')
        HBAI.to_csv(f'data/hbai/{name}.csv')
    return

def children_in_low_income_families():
    for JSON in CLIF_JSONS:
        CLIF = query_to_pandas(STATXPLORE_API_KEY, JSON).reset_index()
        GEOLOOKUP_DF = pd.read_csv(GEOLOOKUP)
        
        name_to_code_dict = dict(list(zip(GEOLOOKUP_DF.LAD22NM, GEOLOOKUP_DF.LAD22CD)))
        CLIF.rename(columns=name_to_code_dict, inplace=True, errors="raise")    
        CLIF['variable_name'] = 'children_in_low_income'
        #@TODO rewrite below so its not hard-coded.
        ids = ['Year', 'Age of Child (years and bands)', 'Gender of Child', 'Family Type', 'Work Status', 'variable_name']
        CLIF_long = pd.melt(CLIF, id_vars=ids, value_vars=CLIF.columns.to_list()[5:], var_name='geography_code')
        CLIF_long.set_index(ids, inplace=True)
        
        #write to csv
        os.makedirs('data/clif', exist_ok=True)
        CLIF_long.to_csv(f'data/clif/clif_{JSON[-8:-5]}.csv')
    return

if __name__ == '__main__':
    
    houses_below_avg_income()
    children_in_low_income_families()