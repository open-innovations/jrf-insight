import os
import pandas as pd
from util import *

data = load_data(filepath='data/example-vis.csv', skiprows=10, nrows=432, names=["Measures", "Type of Individual by Age Category", "Financial Year", "60 per cent of median net household income (BHC) in latest prices",
                 "Location in the United Kingdom of the Household of the Individual (please calculate three-year averages - click on i for the correct method) (3ya)", "Count", "RSE", "Annotations"])

# get the latest date available for the data
date_str, date_series = latest_date(data)

# filter the data to make a dashboard
dashboard = data[(data["Type of Individual by Age Category"] != 'Total')
                 & (data["Financial Year"] == date_str)
                 & (data["Location in the United Kingdom of the Household of the Individual (please calculate three-year averages - click on i for the correct method) (3ya)"] == 'Total')
                 & (data["60 per cent of median net household income (BHC) in latest prices"] == "In low income (below threshold)")].set_index('Measures')

# filter the data to make a line chart and drop unused columns
line_chart = data[(data["Type of Individual by Age Category"]
                  == "Child")
                  & (data["60 per cent of median net household income (BHC) in latest prices"] == "In low income (below threshold)")].drop(columns=['Measures', 'RSE', '60 per cent of median net household income (BHC) in latest prices', "Type of Individual by Age Category", "Annotations"]
                                                                                                                                           )

line_chart = line_chart[(line_chart["Financial Year"] != "2020-21 (covid2021)")
                        & (line_chart["Financial Year"] != 'Total')]

line_chart = line_chart.pivot(
    index="Financial Year", columns='Location in the United Kingdom of the Household of the Individual (please calculate three-year averages - click on i for the correct method) (3ya)', values='Count')

# bar chart
bar_chart = data[(data["Type of Individual by Age Category"] != 'Total') &
                 (data["Financial Year"] == date_str) &
                 (data["60 per cent of median net household income (BHC) in latest prices"] == "In low income (below threshold)")]

bar_chart = bar_chart.pivot(index="Location in the United Kingdom of the Household of the Individual (please calculate three-year averages - click on i for the correct method) (3ya)",
                            columns="Type of Individual by Age Category", values='Count')

# hex map
name_to_code = {'Yorkshire and The Humber (E12000003)': 'E12000003', 'North West (E12000002)': 'E12000002', 'North East (E12000001)': 'E12000001'}
hex_map = bar_chart.rename(index=name_to_code).drop('Total')
hex_map.index.names = ['geography_code']
hex_map = hex_map.astype(float, errors='ignore')

# make the output directory
OUTDIR = 'src/_data/example/'
os.makedirs(OUTDIR, exist_ok=True)

# write to file
dashboard.to_csv(os.path.join(OUTDIR, 'dashboard.csv'))
line_chart.to_csv(os.path.join(OUTDIR, 'line_chart.csv'))
bar_chart.to_csv(os.path.join(OUTDIR, 'bar_chart.csv'))
hex_map.to_csv(os.path.join(OUTDIR, 'hex_map.csv'))
date_series.to_json(os.path.join(OUTDIR, 'stats.json'), index="orient")
