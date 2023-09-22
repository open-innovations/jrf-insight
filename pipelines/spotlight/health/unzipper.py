import zipfile

TOP_DIR = '../../..'
EXTRACT_DIR = f'{TOP_DIR}/data-raw/school-pupils-characteristics'
archive_format = "zip"


def unzip(zipped_fp, files_to_extract):
    try:
        with zipfile.ZipFile(zipped_fp) as zf:
            for f in files_to_extract:
                zf.extract(f, EXTRACT_DIR)
        print("Archive unpacked successfully")
    except:
        print("Unable to unpack archive")
    return


if __name__ == '__main__':
    unzip(
        zipped_fp=f"{TOP_DIR}/data-raw/school-pupils-characteristics/school-pupils-and-their-characteristics.zip",
        files_to_extract=['data/spc_pupils_fsm.csv', 'data-guidance/data-guidance.txt']
    )
