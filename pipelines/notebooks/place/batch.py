import yaml

from prepare import process, shared_data

if __name__ == "__main__":
    shared_data()
    with open('places.yaml') as f:
        places = yaml.safe_load(f.read())
    for place in places:
        process(place)