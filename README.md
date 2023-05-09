# jrf-insight
JRF North England Insight Finder

[Project hub page on Open Innovations website](https://open-innovations.org/projects/jrf/north-insight-finder/)

Install pipenv with `pip install pipenv`. To install dependencies use `pipenv install`. To activate the virtual environment, use `pipenv shell`. 

`pipelines` contains the subfolders - `extract` `transform` and `prepare`, where we extract the data, transform it into a required shapem and prepare it for visualisation.

You can run pipelines using DVC. Run `dvc init` to initialise the directory. Then `dvc repro pipelines/<stage>/dvc.yaml` to run the pipelines. If there are no changes to files, the stage will skip.

`test.json` details the data to be requested from [Stat-Xplore](https://stat-xplore.dwp.gov.uk/webapi/jsf/login.xhtml). This can be downloaded from the website once you have made the datatable you want to include in the pipeline.

We currently store the test data in csv format in `working`. In future, we will store transformed and prepared data in a dedicated `data` directory. The structure will develop as the project does.
