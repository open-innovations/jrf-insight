import placeData from './place_data.json' assert { type: "json" };

const onlyUnique = <T>(value: T, index: number, arr: T[]) => {
  return arr.indexOf(value) === index;
}

/**
 * Returns the place data for a list of places
 * 
 * @param codes geography codes to find
 * @returns 
 */
export function getPlaceData(codes: Array<string>) {
  return placeData.filter(x => codes.includes(x.geography_code));
}

/**
 * Returns the place data for a single place
 * 
 * @param code geography code to find
 * @returns 
 */
export function getDataForPlace(code: string) {
  return placeData.find(x => x.geography_code === code);
}

/**
 * Returns the place data for a list of places, preserving ordering
 * 
 * @param codes geography codes to find
 * @returns 
 */
export function getDataForPlaces(codes: Array<string>) {
  return codes.map(getDataForPlace);
}

/**
 * Provide a list of all places
 */
export function listAllPlaces(): string[] {
  return placeData.map(x => x.geography_code).filter(onlyUnique);
}

/**
 * Get basic place data lookup
 */
export function getPlaceDataLookup() {
  return placeData.reduce((result, {
    geography_code,
    name,
    type,
    ancestors,
    parents,
    children,
  }) => ({
    ...result,
    [geography_code]: {
      key: geography_code,
      name,
      type,
      ancestors,
      parents,
      children,
    }
  }), {});
}