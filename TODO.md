Cleanup

Data Structure

- [ ] Move `interim` to different location
- [ ] Use duckdb PIVOT clauses
- [ ] Map out flow of data through the pipelines
- [ ] Pivot rental prices in duck

proposed new structure

- data
    - raw - as downloaded from API / site, etc
    - transformed - as transformed into normalised format
    - prepared (ex interim - ready to be used on the site)
    - working - for temporary working files, logs, errors, etc

Pipelines

- [ ] Review transform script in place

Non-DVC data files:

- [ ] free school meals (need to update to most recent data https://explore-education-statistics.service.gov.uk/find-statistics/school-pupils-and-their-characteristics and use file `spc_pupils_fsm.xlsx` and possibly `spc_uifsm.xlsx` too.)
- [ ] personal-wellbeing-survey (latest data: https://www.ons.gov.uk/datasets/wellbeing-local-authority/editions/time-series/versions/3.csv )