import sys
import os
import json

import pandas as pd
import geopandas as gpd

from params import DATA_DIR, SRC_DATA_DIR, OUTPUT_DIR



class PlaceMetadata:
    def __init__(self):
        place_metadata_file = f'{SRC_DATA_DIR}/places.json'
        with open(place_metadata_file) as f:
            self.data = json.loads(f.read())

    def get_all_codes_for_code(self, code):
        return [code] + self.data[code].get('children', [])

    def get_direct_children_for_code(self, code):
        return self.data[code].get('direct_children', [])


class PlaceData:
    def __init__(self):
        self.data = pd.read_parquet(f'{DATA_DIR}/interim/place_data.parquet')

    def filter_by_codes(self, codes):
        return self.data[self.data.index.isin(codes)]


class Shapes:
    def __init__(self):
        self.data = gpd.read_parquet(f'{DATA_DIR}/interim/shapes.parquet')

    def filter_by_codes(self, codes):
        return self.data[self.data.index.isin(codes)]


def save_file(data, path):
    data.to_csv(f'{path}/place_data.csv')


def save_geojson(data, path, filename):
    with open(f'{path}/{filename}', 'w') as f:
        f.write(data.to_json())


all_place_data = PlaceData()


def shared_data():
    os.makedirs(OUTPUT_DIR, exist_ok=True)
    with open(f'{OUTPUT_DIR}/_data.yml', 'w') as f:
        f.write('layout: templates/place.njk\ntags:\n  - place\n')


def process(geography_code):
    PLACE_DIR = f'{OUTPUT_DIR}/{geography_code}/'
    os.makedirs(PLACE_DIR + "_data/", exist_ok=True)

    this_place = all_place_data.filter_by_codes([geography_code]).iloc[0]

    with open(f"{PLACE_DIR}/index.njk", "w") as f:
        f.write(
            '---\nkey: ' + geography_code +
            '\ntitle: ' + this_place['name'] +
            '\ntype: ' + this_place['type'] +
            '\n---\n'
        )

    relations = {
        'descendants': this_place['children'].tolist(),
        'children': this_place['direct_children'].tolist(),
        'parents': this_place['direct_parents'].tolist(),
    }

    with open(f"{PLACE_DIR}/_data/relations.json", "w") as f:
        f.write(json.dumps(relations))

    geography_codes = [geography_code] + relations['descendants']

    place_data = all_place_data.filter_by_codes(geography_codes)

    place_data.drop(columns=['children', 'direct_children', 'direct_parents', 'name', 'type']).pipe(
        save_file, PLACE_DIR + "_data/"
    )

    codes = relations['children']
    if len(codes) < 1:
        codes = [geography_code]
    geojson = Shapes().filter_by_codes(codes)
    geojson.pipe(save_geojson, PLACE_DIR + "_data/", 'map.geojson')


if __name__ == '__main__':
    geography_code: str = sys.argv[1]
    process(geography_code)
