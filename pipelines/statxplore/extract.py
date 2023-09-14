import logging
import os

import pandas as pd

from api import run_statxplore_query

logging.basicConfig(encoding="utf-8", level=logging.DEBUG)

ROOT_DIR = os.path.abspath(os.path.dirname(__file__) + "/../..")

GEOLOOKUP = f"{ROOT_DIR}/data/geo/geography_lookup.csv"
HBAI_JSON = f"{ROOT_DIR}/pipelines/statxplore/json/data/HBAI.json"
CLIF_JSONS = [
    f"{ROOT_DIR}/pipelines/statxplore/json/data/CLIF_REL.json",
    f"{ROOT_DIR}/pipelines/statxplore/json/data/CLIF_ABS.json",
]
SMI_households = f"{ROOT_DIR}/pipelines/statxplore/json/data/SMI_households.json"
SMI_amount = f"{ROOT_DIR}/pipelines/statxplore/json/data/SMI_amount.json"
HB_JSONS = [
    f"{ROOT_DIR}/pipelines/statxplore/json/data/Housing Benefit/claimants_region.json",
    f"{ROOT_DIR}/pipelines/statxplore/json/data/Housing Benefit/claimants_LA.json",
    f"{ROOT_DIR}/pipelines/statxplore/json/data/Housing Benefit/claimants_ward.json",
]

GEOLOOKUP_DF = pd.read_csv(GEOLOOKUP)


def children_in_low_income_families(output_dir="data/clif"):
    for JSON in CLIF_JSONS:
        CLIF = run_statxplore_query(JSON).reset_index()

        name_to_code_dict = dict(list(zip(GEOLOOKUP_DF.LAD22NM, GEOLOOKUP_DF.LAD22CD)))
        CLIF.rename(columns=name_to_code_dict, inplace=True, errors="raise")
        CLIF["variable_name"] = "children_in_low_income"
        # @TODO rewrite below so its not hard-coded.
        ids = [
            "Year",
            "Age of Child (years and bands)",
            "Gender of Child",
            "Family Type",
            "Work Status",
            "variable_name",
        ]
        CLIF_long = pd.melt(
            CLIF,
            id_vars=ids,
            value_vars=CLIF.columns.to_list()[5:],
            var_name="geography_code",
        )
        CLIF_long.set_index(ids, inplace=True)

        # write to csv
        os.makedirs(output_dir, exist_ok=True)
        filename = os.path.splitext(os.path.basename(JSON))[0].replace("CLIF", "clif")
        CLIF_long.to_csv(f"{output_dir}/{filename}.csv")
    return


def support_mortgage_interest(JSON, variable_name, output_dir="data/smi"):
    SMI = run_statxplore_query(JSON).reset_index()
    name_to_code_dict = dict(list(zip(GEOLOOKUP_DF.RGN22NM, GEOLOOKUP_DF.RGN22CD)))
    SMI.rename(columns=name_to_code_dict, inplace=True, errors="raise")
    SMI["Quarter"] = pd.to_datetime(SMI["Quarter"], format="%b-%y").dt.strftime("%Y-%m")
    SMI = SMI.melt(
        id_vars=["Quarter"],
        value_vars=["E12000001", "E12000002", "E12000003"],
        var_name="geography_code",
    )
    SMI["variable_name"] = variable_name
    os.makedirs(output_dir, exist_ok=True)
    SMI.to_csv(f"{output_dir}/{variable_name}.csv")
    return SMI


def housing_benefit_claimants(JSON, name_type, code_type):
    HB = run_statxplore_query(JSON).reset_index()
    name_to_code_dict = dict(
        list(zip(GEOLOOKUP_DF[f"{name_type}"], GEOLOOKUP_DF[f"{code_type}"]))
    )
    HB.rename(columns=name_to_code_dict, inplace=True, errors="ignore")
    HB["Month"] = HB["Month"].str.split().str[0]
    HB["Month"] = pd.to_datetime(HB["Month"], format="%Y%m").dt.strftime("%Y-%m")
    return HB


if __name__ == "__main__":
    children_in_low_income_families()

    support_mortgage_interest(SMI_households, "smi_loans_in_payment_households")
    support_mortgage_interest(SMI_amount, "smi_in_payment_amount")

    HB_RGN = housing_benefit_claimants(HB_JSONS[0], "RGN22NM", "RGN22CD")
    HB_LA = housing_benefit_claimants(HB_JSONS[1], "LAD22NM", "LAD22CD")
    HB_WD = housing_benefit_claimants(HB_JSONS[2], "WD22NM", "WD22CD")
    HB_joined = pd.concat(
        [
            housing_benefit_claimants(HB_JSONS[0], "RGN22NM", "RGN22CD"),
            housing_benefit_claimants(HB_JSONS[1], "LAD22NM", "LAD22CD"),
            housing_benefit_claimants(HB_JSONS[2], "WD22NM", "WD22CD"),
        ]
    )
    value_vars = HB_joined.columns.to_list()
    geography_codes = [i for i in value_vars if i.startswith("E") and len(i) == 9]
    HB = HB_joined.melt(
        id_vars=["Month"], value_vars=geography_codes, var_name="geography_code"
    )
    HB = HB[HB.value.notnull()]
    HB["variable_name"] = "HB_claimants"
    os.makedirs("data/HB", exist_ok=True)
    HB.to_csv(f"data/HB/claimants.csv")
    # print(HB)
