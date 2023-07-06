import placeData from './place_data.json' assert { type: "json" };

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