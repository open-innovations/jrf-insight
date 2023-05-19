import pandas as pd
def slugify(s):
    #TODO try replace '\W+'
    return re.sub(r'[\*\-\(\)\s\,\"\(/)]+', '_', s.lower())

def load_data(filepath, **kwargs):
    #header = kwargs['header']
    nrows = kwargs['nrows']
    skiprows = kwargs['skiprows']
    names = kwargs['names']
    return pd.read_csv(filepath, names=names, skiprows=skiprows, nrows=nrows) #, nrows=nrows)

def latest_date(data, colname="Financial Year"):
    '''
        Returns string for use in scripts,
        and series to write to file.
    '''
    return data[data[colname] != 'Total'][colname].max(), pd.Series(data=data[data[colname] != 'Total'][colname].max(), index=['latest_date'], name='date')

# def csv_maker(data, OUTDIR, name):
#     return 
#@TODO make a csv writer