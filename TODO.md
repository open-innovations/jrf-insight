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