import json
import yaml
import pandas as pd
from params import DATA_DIR

place_file = f'{DATA_DIR}/interim/place_data.parquet'

place_data = pd.read_parquet(place_file)

place_codes = place_data.index[~place_data.index.duplicated()]

with open('places.yaml', 'w') as f:
    f.write(yaml.dump(place_codes.to_list()))