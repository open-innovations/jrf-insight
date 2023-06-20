# jrf-insight

JRF North England Insight Finder

[Project hub page on Open Innovations website](https://open-innovations.org/projects/jrf/north-insight-finder/)

## StatXplore

You need to register for an account and get an open data API key. You'll need to
add this `STATXPLORE_API_KEY=<your_key>` to a `.env` file at the top level
directory (_Make sure this is added to .gitignore_). Without this, you will not
have permission to pull data from stat-xplore.

## Pipenv

Install pipenv with `pip install pipenv`. To install dependencies use
`pipenv install`. To activate the virtual environment, use `pipenv shell`. If
you are on windows you may need to install windows subsytem for linux, and
install pip and then pipenv in a linux environment. Dependencies in the
`pipfile` are detailed in `Pipfile.lock`.

## Pipelines / DVC

`pipelines` contains the subfolders - `extract` `transform` and `prepare`, where
we extract the data, transform it into a required shapem and prepare it for
visualisation. These are different "stages".

The `extract` folder contains the stages `probe`: make the lookups for everything available in statxplore, `describe`: make metadata for the datasets, `extract`: get the data from files in `json/data`.

You can run pipelines using DVC. Run `dvc init` to initialise the directory.
Then `dvc repro pipelines/<stage>/dvc.yaml` to run the pipelines. If there are
no changes to files, the stage will skip.

## Data

Lookups for the statXplore API requests stored in `data/lookups`. Data is stored in `data/csv`. This data has been accessed and used in accordance with the [Open Government License](https://www.nationalarchives.gov.uk/doc/open-government-licence/version/3/)
