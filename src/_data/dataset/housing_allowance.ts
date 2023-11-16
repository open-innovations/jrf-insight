import { connection, run } from "../../../data/interim/duck.ts";

export const shortfall_for_geo = (place: string) => {
  const result = run(
  () => connection.query(`
    SELECT property_name, LHA_shortfall
    FROM './data/local-housing-allowance/local-housing-allowance.parquet'
    WHERE geography_code == '${place}'
  `));
  
  const property_name_lookup = {
    room: "Single room",
    bed1: "One bedroom",
    bed2: "Two bedroom",
    bed3: "Three bedroom"
  }
  return result.map(x => ({
    ...x,
    property_name: property_name_lookup[x.property_name] || x.property_name
  }));
}

export const range = connection.query(`
  SELECT
    FLOOR(MIN(LHA_shortfall)/10)*10 AS lha_shortfall_min,
    CEIL(MAX(LHA_shortfall)/10)*10 AS lha_shortfall_max
  FROM './data/local-housing-allowance/local-housing-allowance.parquet';
`);

