# jrf-insight

JRF North England Insight Finder

[Project hub page on Open Innovations website](https://open-innovations.org/projects/jrf/north-insight-finder/)

## StatXplore

To run the pipelines you need to register for an account and get an open data API key. You'll need to
add this `STATXPLORE_API_KEY=<your_key>` to a `.env` file at the top level
directory (_Make sure this is added to .gitignore_). Without this, you will not
have permission to pull data from stat-xplore.

## Pipenv
If you are on windows you should install windows subsytem for linux, and
install pip and then pipenv in a linux environment. Use `bash` to enter your linux virtual machine.
Install pipenv with `pip install pipenv`.To activate the virtual environment, use `pipenv shell`.  
To install python libraries use`pipenv install <library-name>`. 
Dependencies in the `pipfile` are detailed in `Pipfile.lock`.

## Pipelines / DVC

Our pipelines are managed using `dvc`. You can re-run all the pipelines using `dvc repro -R pipelines`, 
or an individual pipeline using `dvc repro pipelines/<name>/dvc.yaml`. 

`statxplore` is the pipeline for getting data from the DWP's statXplore database. It has 3 stages. `probe.py` gets lookups for
the api calls for the measures, dimensions and database names of every database in statXplore. These are located
in `data/lookups`. `describe.py` gets metadata about every database. `extract` gets actual data from statxplore 
using `.json` API requests, which are kept in `statxplore/json/data`. 

`place` generates all the place `.geojson` files and the data that is associated with each place page on the site.

`fingertips` will be used to scrape data from Public Health England's database.

`metadata` is the pipeline to create the metadata section of the site.
## Data
Raw datasets are stored in `data-raw/`. These are files that come straight from their source and are entirely unprocessed. 
They are then transformed using files in the `R` directory and saved in `data/`. 

Transformed data is stored in `data/`. Data in this folder is prepared using `pipelines/place/transform.ipynb` and `duckdb`
to drive the visualisations on the site. In general, `transform.ipynb` produces most-recent data that goes in tables or 
dashboard blocks. `duckdb` is used to select and pivot data that powers time-series or multi-series visualisations
(e.g. line charts and bar charts). 

All ONS and Government data is openly available and has been accessed and used in accordance with the [Open Government License](https://www.nationalarchives.gov.uk/doc/open-government-licence/version/3/). 

## resources
Contains meeting notes, useful links and ideas.

## src
Contains the site build.

## playground
Experiments including inital attempts at modelling data.