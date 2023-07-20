from multiprocessing import Pool, cpu_count
import yaml


from progress.bar import Bar
from prepare import process, shared_data

chunksize = cpu_count()

if __name__ == "__main__":
    shared_data()
    with open('places.yaml') as f:
        places = yaml.safe_load(f.read())
    chunks = [places[i:i+chunksize] for i in range(0, len(places), chunksize)]

    with Pool(processes=chunksize) as pool, Bar('Processing', max=len(places)) as bar:
        for chunk in chunks:
            pool.map(process, chunk)
            bar.next(len(chunk))