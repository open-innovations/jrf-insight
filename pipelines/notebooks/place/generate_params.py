import json
import yaml

place_file = '../../../src/_data/places.json'

with open(place_file) as f:
    place_keys = list(json.loads(f.read()).keys())


params = {
    'places': place_keys
}

with open('params.yaml', 'w') as f:
    f.write(yaml.dump(params))