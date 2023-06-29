import placeData from './place_data.json' assert { type: "json" };

export function getPlaceData(codes: Array<string>) {
  return placeData.filter(x => codes.includes(x.geography_code));
}
