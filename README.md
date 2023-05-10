# jrf-insight
JRF North England Insight Finder

[Project hub page on Open Innovations website](https://open-innovations.org/projects/jrf/north-insight-finder/)

## Pipenv 
Install pipenv with `pip install pipenv`. To install dependencies use `pipenv install`. To activate the virtual environment, use `pipenv shell`. If you are on windows you may need to install windows subsytem for linux, and install pip and then pipenv in a linux environment. Dependencies in the `pipfile` are detailed in `Pipfile.lock`.

## Pipelines / DVC
`pipelines` contains the subfolders - `extract` `transform` and `prepare`, where we extract the data, transform it into a required shapem and prepare it for visualisation. These are different "stages".

You can run pipelines using DVC. Run `dvc init` to initialise the directory. Then `dvc repro pipelines/<stage>/dvc.yaml` to run the pipelines. If there are no changes to files, the stage will skip.

## Data
We currently store the test data in csv format in `working`. In future, we will store transformed and prepared data in a dedicated `data` directory. The structure will develop as the project does.
