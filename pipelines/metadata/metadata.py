import os
import re
import pandas as pd


def make_key(s: str, sep='-'):
      return re.sub(r'\W+', sep, s.lower()).strip(sep)

class Dimension:
    def __init__(self, series: pd.Series):
        self.name = series.name
        self.values = series.unique().tolist()

    def __repr__(self):
        return f'Dimension->{self.name}'
    
    def to_dict(self):
        return self.__dict__

class Fact:
    def __init__(self, series: pd.Series):
        self.name = series.name
        self.type = str(series.dtype)
        self.description = series.describe().to_dict()
        self.na = series.isna().sum()

    def __repr__(self):
        return f'Fact->{self.name} ({self.type})'

    def to_dict(self):
        return self.__dict__


class Metadata:
    def load(
        self,
        dataset_path: str,
        loader=pd.read_csv,
        variables=None,
        values=None,
        ignored=None,
        root_dir='',
        id=None,
        group=None
    ):
        if variables is None:
              variables = ['variable_name']
        if values is None:
              values = ['value']
        if ignored is None:
              ignored = []

        self.id = id or make_key(os.path.basename(dataset_path))
        self.group = group or os.path.dirname(dataset_path).replace(os.sep, '.')

        try:
            dataset: pd.DataFrame = loader(os.path.join(root_dir, dataset_path))
        except:
            raise Exception('Error loading %s', dataset_path)

        # Process variables
        fact_columns = variables + values
        dimension_columns = [c for c in dataset.columns.to_list() if c not in fact_columns + ignored]

        # Clean up duplicates
        dataset = dataset[~dataset.duplicated(subset=dimension_columns)]

        try:
              facts = dataset.pivot(index=dimension_columns, columns=variables, values=values).reset_index(drop=True)
        except Exception:
              return None
        facts.columns = facts.columns.droplevel()
        self.facts = [Fact(f) for _, f in facts.items()]

        # Calculate dimension columns
        self.dimensions = [Dimension(x[1]) for x in dataset.loc[:, dimension_columns].items()]

        return self
  
    def __repr__(self):
        return f'Metadata->{self.dimensions}->{self.facts}'

    def to_dict(self):
        result = {k: v for k, v in self.__dict__.items() if k not in ['facts', 'dimensions']}
        result['facts'] = [f.to_dict() for f in self.facts]
        result['dimensions'] = [d.to_dict() for d in self.dimensions]
        return result

