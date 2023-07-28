import pandas as pd
from utils import *
from describe import query_to_pandas
import json

GEOLOOKUP = "data/geo/geography_lookup.csv"
HBAI_JSON = 'pipelines/statxplore/json/data/HBAI.json'
CLIF_JSONS = ['pipelines/statxplore/json/data/CLIF_REL.json', 'pipelines/statxplore/json/data/CLIF_ABS.json']
SMI_households = 'pipelines/statxplore/json/data/SMI_households.json'
SMI_amount = 'pipelines/statxplore/json/data/SMI_amount.json'
HB_JSONS = ['pipelines/statxplore/json/data/Housing Benefit/claimants_region.json',
            'pipelines/statxplore/json/data/Housing Benefit/claimants_LA.json',
            'pipelines/statxplore/json/data/Housing Benefit/claimants_ward.json']
#dates = ['1011', '1112', '1213', '1314', '1415', '1516', '1617', '1718', '1819', '1920', '2021', '2122']
GEOLOOKUP_DF = pd.read_csv(GEOLOOKUP)

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
        
        HBAI = query_to_pandas(STATXPLORE_API_KEY, 'pipelines/statxplore/json/data/HBAI.json').reset_index()
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

def support_mortgage_interest(JSON, variable_name):
    SMI = query_to_pandas(STATXPLORE_API_KEY, JSON).reset_index()
    name_to_code_dict = dict(list(zip(GEOLOOKUP_DF.RGN22NM, GEOLOOKUP_DF.RGN22CD)))
    SMI.rename(columns=name_to_code_dict, inplace=True, errors="raise")
    SMI['Quarter'] = pd.to_datetime(SMI['Quarter'], format='%b-%y').dt.strftime('%Y-%m')
    SMI = SMI.melt(id_vars=["Quarter"], value_vars=['E12000001', 'E12000002', 'E12000003'], var_name="geography_code")
    SMI['variable_name'] = variable_name
    os.makedirs('data/smi', exist_ok=True)
    SMI.to_csv(f'data/smi/{variable_name}.csv')
    return SMI

def housing_benefit_claimants(JSON, name_type, code_type):
    HB = query_to_pandas(STATXPLORE_API_KEY, JSON).reset_index()
    name_to_code_dict = dict(list(zip(GEOLOOKUP_DF[f'{name_type}'], GEOLOOKUP_DF[f'{code_type}'])))
    #print(name_to_code_dict)
    #name_to_code_dict
    #print(len(HB.columns.to_list()))
    HB.rename(columns=name_to_code_dict, inplace=True, errors="ignore")
    HB['Month'] = HB['Month'].str.split().str[0]
    HB['Month'] = pd.to_datetime(HB['Month'], format='%Y%m').dt.strftime('%Y-%m')
    return HB
if __name__ == '__main__':
    
    houses_below_avg_income()
    children_in_low_income_families()
    support_mortgage_interest(SMI_households, 'smi_loans_in_payment_households')
    support_mortgage_interest(SMI_amount, 'smi_in_payment_amount')
    HB_RGN = housing_benefit_claimants(HB_JSONS[0], "RGN22NM", "RGN22CD")
    HB_LA = housing_benefit_claimants(HB_JSONS[1], "LAD22NM", "LAD22CD")
    HB_WD = housing_benefit_claimants(HB_JSONS[2], "WD22NM", "WD22CD")
    HB_joined = pd.concat([
        HB_RGN,
        HB_LA,
        HB_WD
    ])
    value_vars = HB_joined.columns.to_list()
    geography_codes = [i for i in value_vars if i.startswith('E') and len(i) == 9]
    HB = HB_joined.melt(id_vars=["Month"], value_vars=geography_codes, var_name="geography_code")
    HB = HB[HB.value.notnull()]
    HB['variable_name'] = 'HB_claimants'
    os.makedirs('data/HB', exist_ok=True)
    HB.to_csv(f'data/HB/claimants.csv')
    #print(HB)