import sys
import os
import pandas as pd
import json

DATA_DIR = '../../../data'
OUTPUT_DIR = '../../../src/_data'


def get_place_metadata():
    place_metadata_file = f'{OUTPUT_DIR}/places.json'
    with open(place_metadata_file) as f:
        place_metadata = json.loads(f.read())[geography_code]
    return place_metadata


def get_geography_codes(place_metadata):
    geography_codes = [geography_code]
    if 'children' in place_metadata:
        geography_codes = geography_codes + place_metadata['children']
    return geography_codes


def get_population_data(code_list):
    population_data = pd.read_csv(
        f'{DATA_DIR}/population-estimates/population-estimates.csv')
    return population_data[population_data.geography_code.isin(
        code_list)].drop_duplicates()


def get_council_tax_data(code_list):
    council_tax_data = pd.read_csv(
        f'{DATA_DIR}/council-tax-support/council-tax-support.csv')
    most_recent_date = max(council_tax_data.date)
    return council_tax_data[council_tax_data.geography_code.isin(
        code_list) & (council_tax_data.date == most_recent_date)]

def get_children_low_income_data(code_list):
    clif_data = pd.read_csv(
        f'{DATA_DIR}/clif/clif_REL.csv')
    most_recent_date = max(clif_data.Year)
    clif_data = clif_data[(clif_data['Age of Child (years and bands)'] == 'Total') &
                          (clif_data['Gender of Child'] == 'Total') &
                          (clif_data['Family Type'] == 'Total') &
                          (clif_data['Work Status'] == 'Total')]
    return clif_data[clif_data.geography_code.isin(code_list)
                     & (clif_data.Year == most_recent_date)]

def combine_data(*args):
    return pd.concat(args)


def make_table(data):
    return data.pivot(index='geography_code', columns='variable_name', values='value')


def save_file(data, path):
    data.to_csv(f'{path}/place_data.csv')


if __name__ == '__main__':
    geography_code: str = sys.argv[1]
    PLACE_DIR = f'{OUTPUT_DIR}/place_data/{geography_code}/'
    os.makedirs(PLACE_DIR, exist_ok=True)

    place_metadata = get_place_metadata()

    geography_codes = get_geography_codes(place_metadata)

    combine_data(
        get_population_data(geography_codes),
        get_council_tax_data(geography_codes),
        get_children_low_income_data(geography_codes)
    ).pipe(
        make_table
    ).pipe(
        save_file, PLACE_DIR
    )
