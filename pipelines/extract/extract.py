import os
import json
import pandas as pd
from statxplore import objects
from utils import session

path = 'data/csv'
os.makedirs(path, exist_ok=True)
LOOKUP_DIR = 'data/lookups/Households Below Average Income/Households Below Average Income/'
database = pd.read_csv(os.path.join(LOOKUP_DIR, 'database.csv')).iloc[0]['database']

table = objects.Table(database).run_query(session, measures=['str:count:HBAI:V_F_HBAI'], dimensions=[
    ['str:field:HBAI:V_F_HBAI:YEAR'], ['str:field:HBAI:V_F_HBAI:SEX']])
