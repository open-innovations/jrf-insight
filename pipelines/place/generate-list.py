import yaml
import pandas as pd
from params import DATA_DIR

shapes_file = f'{DATA_DIR}/interim/shapes.parquet'

shapes_data = pd.read_parquet(shapes_file)

place_codes = shapes_data.index[~shapes_data.index.duplicated()]

with open('places.yaml', 'w') as f:
    f.write(yaml.dump(place_codes.to_list()))