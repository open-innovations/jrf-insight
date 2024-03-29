import { connection } from "../../../data/interim/duck.ts";

export const getInfographicValuesForPlace = (placeCode: string) => {
  const percentage_benefits_claimants = connection.query(`
    SELECT CAST(value AS DOUBLE) AS value
    FROM './data-mart/claimant-count/claimant-count.parquet'
    WHERE geography_code=='${placeCode}'
    AND variable_name=='Claimants as a proportion of residents aged 16-64'
    LIMIT 1;
  `).shift()?.value;

  const proportion_fuel_poverty = connection.query(`
    SELECT CAST(value AS DOUBLE) as value
    FROM './data-mart/fuel-poverty/fuel-poverty.parquet'
    WHERE geography_code=='${placeCode}'
    AND variable_name=='Proportion of households fuel poor (%)'
    ORDER BY date DESC
    LIMIT 1;
  `).shift()?.value;

  return {
    percentage_benefits_claimants,
    proportion_fuel_poverty,
    people_in_deprived_places: 50,
  };
};

