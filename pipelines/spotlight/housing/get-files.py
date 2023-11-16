import os

import requests


def save(url, filename):
    r = requests.get(url)
    with open(filename, 'wb') as f:
        f.write(r.content)


if __name__ == "__main__":
    OUTPUT_DIR = os.path.join(os.path.dirname(
        __file__), '../../../data-raw/dwelling-stock')
    os.makedirs(OUTPUT_DIR, exist_ok=True)

    # https://www.ons.gov.uk/peoplepopulationandcommunity/housing/datasets/subnationaldwellingstockbytenureestimates
    save('https://www.ons.gov.uk/file?uri=/peoplepopulationandcommunity/housing/datasets/subnationaldwellingstockbytenureestimates/current/subnationaldwellingsbytenure2021.xlsx',
         f'{OUTPUT_DIR}/subnationaldwellingstockbytenure2021.xlsx')
