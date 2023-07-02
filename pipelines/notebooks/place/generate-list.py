import json
import yaml
import pandas as pd

place_file = '../../../data/interim/place_data.parquet'

place_data = pd.read_parquet(place_file)

place_codes = place_data.index[~place_data.index.duplicated()]

with open('places.yaml', 'w') as f:
    f.write(yaml.dump(place_codes.to_list()))