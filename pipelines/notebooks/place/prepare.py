import sys
import os
import pandas as pd
import json

DATA_DIR = '../../../data'
SRC_DATA_DIR = '../../../src/_data'
OUTPUT_DIR = '../../../src/place'


class PlaceMetadata:
    def __init__(self):
        place_metadata_file = f'{SRC_DATA_DIR}/places.json'
        with open(place_metadata_file) as f:
            self.data = json.loads(f.read())

    def get_all_codes_for_code(self, code):
        return [code] + self.data[code].get('children', [])


class PlaceData:
    def __init__(self):
        self.data = pd.read_parquet(f'{DATA_DIR}/interim/place_data.parquet')

    def filter_by_codes(self, codes):
        return self.data[self.data.index.isin(codes)]


def save_file(data, path):
    data.to_csv(f'{path}/place_data.csv')


if __name__ == '__main__':
    geography_code: str = sys.argv[1]
    PLACE_DIR = f'{OUTPUT_DIR}/{geography_code}/'
    os.makedirs(PLACE_DIR + "_data/", exist_ok=True)

    all_place_data = PlaceData()

    this_place = all_place_data.filter_by_codes([geography_code]).iloc[0]

    with open(f"{PLACE_DIR}/index.njk", "w") as f:
        f.writelines([
            '---\n',
            f"key: { geography_code }\n",
            f"title: { this_place['name'] }\n",
            f"type: { this_place['type'] }\n",
            '---\n'
        ])

    with open(f"{PLACE_DIR}/_data/all_children.json", "w") as f:
        f.write(json.dumps(this_place['children'].tolist()))

    with open(f"{PLACE_DIR}/_data/direct_children.json", "w") as f:
        f.write(json.dumps(this_place['direct_children'].tolist()))

    with open(f"{PLACE_DIR}/_data/direct_parents.json", "w") as f:
        f.write(json.dumps(this_place['direct_parents'].tolist()))

    geography_codes = PlaceMetadata().get_all_codes_for_code(geography_code)

    place_data = all_place_data.filter_by_codes(geography_codes)

    place_data.drop(columns=['children', 'direct_children', 'name', 'type']).pipe(
        save_file, PLACE_DIR + "_data/"
    )
