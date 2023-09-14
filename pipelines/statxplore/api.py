import os
import statxplorer


STATXPLORE_API_KEY = os.getenv("STATXPLORE_API_KEY")

if STATXPLORE_API_KEY is None:
    raise RuntimeError("Please set the STATEXPORE_API_KEY")


def run_statxplore_query(query):
    explorer = statxplorer.StatXplorer(STATXPLORE_API_KEY)
    results = explorer.fetch_table(query)
    return results["data"]
