import sys
import os
import pandas as pd
import json

DATA_DIR = '../../../data'
OUTPUT_DIR = '../../../src/_data'


class PlaceMetadata:
    def __init__(self):
        place_metadata_file = f'{OUTPUT_DIR}/places.json'
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
    PLACE_DIR = f'{OUTPUT_DIR}/place_data/{geography_code}/'
    os.makedirs(PLACE_DIR, exist_ok=True)

    geography_codes = PlaceMetadata().get_all_codes_for_code(geography_code)

    PlaceData().filter_by_codes(geography_codes).pipe(
        save_file, PLACE_DIR
    )
