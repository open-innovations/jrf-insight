import { connection, run, arrayToDuckSet } from "../../data/interim/duck.ts";

export function listAllPlaces() {
  return run(() => connection.query(`
    SELECT DISTINCT geography_code
    FROM './data-mart/place_data/lookup.parquet'
    WHERE geography_code NOT LIKE 'E11%'
    ORDER BY geography_code;
  `)).map(x => x.geography_code);
}

function relations(placeCode: string) {
  return run(() => connection.query(`
SELECT
  relation_type, 
  relation
FROM './data-mart/place_data/hierarchy.parquet'
WHERE "geography_code" == '${placeCode}'
;`)).reduce((
    a, c
  ) => {
    const { relation_type, relation } = c;
    return {
      ...a,
      [relation_type]: [
        ...(a[relation_type] || []),
        relation
      ]
    }

  }, {});
}

export function getPlaceData(placeCodes: string[]) {
  const place = run(() => connection.query(`
    SELECT
      geography_code,
      name,
      type
    FROM './data-mart/place_data/lookup.parquet'
    WHERE "geography_code" IN ${arrayToDuckSet(placeCodes)};
  `));

  return place.map(x => ({ ...x, ...relations(x.geography_code) }));
}

// This is an alias - may need to force order to be the same as requested order
export const getDataForPlaces = getPlaceData;

export function getDataForPlace(placeCode: string) {
  const place = run(() => connection.query(`
    SELECT
      geography_code AS key,
      name,
      type
    FROM './data-mart/place_data/lookup.parquet'
    WHERE "geography_code" == '${placeCode}';
  `)).pop();

  return {
    ...place,
    ...relations(placeCode),
  };
}

export function getFactsForPlaces(placeCodes: string[]) {
  return connection.query(`
    SELECT
      "Number of persons" as population,
      "Number of households" as number_of_households,
      "Population density" as population_density,
      "Area in sq km" as area,
      percent_in_low_income,
      unemployment_rate_16_64,
      economic_inactivity_16_64,
      children_in_low_income,
      number_of_children,
      imd_average_score,
      imd_children,
      imd_older_people,
      total_low_income,
      gva as gva,
      geography_code,
      name,
      type
    FROM './data/interim/place_data.parquet'
    WHERE geography_code IN ${arrayToDuckSet(placeCodes)};
  `)  
}

export function placeData(placeCode: string) {
  return getFactsForPlaces([placeCode]).pop();
}

export const placeLookup = getDataForPlace;

const SMALL_SITE = Deno.env.get('SMALL_SITE') !== undefined;

const smallSitePivot = 'E06000014';

const smallSitePivotDetails = SMALL_SITE ? getDataForPlace(smallSitePivot): undefined;

const smallSiteFilter = (place: string) => {
  if (!SMALL_SITE) return true;
  if (place === smallSitePivot) return true;
  if (smallSitePivotDetails!.ancestors.includes(place)) return true;
  if (getDataForPlace(place).ancestors.includes(smallSitePivot)) return true;
  return false;
}

export const list = listAllPlaces().filter(smallSiteFilter);

