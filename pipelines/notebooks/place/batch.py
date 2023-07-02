import yaml

from prepare import process

if __name__ == "__main__":
    with open('places.yaml') as f:
        places = yaml.safe_load(f.read())
    for place in places:
        process(place)