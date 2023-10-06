# DVC import

DVC import url not working.

CMD: `dvc import-url https://www.ons.gov.uk/file?uri=/peoplepopulationandcommunity/housing/datasets/subnationaldwellingstockbytenureestimates/current/subnationaldwellingsbytenure2021.xlsx subnationaldwellingstockbytenure2021.xlsx`

There are problems with ONS dvc pulls - they seem to block repeated calls to the same endpoint. These have to be downloaded via python or similar.
