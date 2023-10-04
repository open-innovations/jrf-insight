# Info

Need to automate pulling this dataset
I've tried to `dvc import-url` a dataset but getting a 429 'too many requests' error.

This is the code that needs to run:

`dvc import-url https://download.ons.gov.uk/downloads/datasets/wellbeing-local-authority/editions/time-series/versions/3.csv wellbeing-local-authority.csv --force`
