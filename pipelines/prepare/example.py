import os
import pandas as pd
from util import *

data = load_data(filepath='data/example-vis.csv', skiprows=10, nrows=432, names=["Measures", "Type of Individual by Age Category", "Financial Year", "60 per cent of median net household income (BHC) in latest prices",
                 "Location in the United Kingdom of the Household of the Individual (please calculate three-year averages - click on i for the correct method) (3ya)", "Count", "RSE", "Annotations"])
date_str, date_series = latest_date(data)
#print(most_recent_year)
headline_stats = data[(data["Type of Individual by Age Category"] != 'Total')
                      & (data["Financial Year"] == date_str)
                      & (data["60 per cent of median net household income (BHC) in latest prices"] == "In low income (below threshold)")].set_index('Measures')
OUTDIR = 'src/_data/'
os.makedirs(OUTDIR, exist_ok=True)

headline_stats.to_csv(os.path.join(OUTDIR, 'example_vis.csv'))
date_series.to_json(os.path.join(OUTDIR, 'stats.json'), index="orient")