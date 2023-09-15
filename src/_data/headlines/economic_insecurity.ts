import { connection } from "../../../data/interim/duck.ts";

export const getInfographicValuesForPlace = (placeCode: string) => {
  const percentage_benefits_claimants = connection.query(`
    SELECT value
    FROM claimants
    WHERE geography_code=='${placeCode}'
    AND variable_name=='Claimants as a proportion of residents aged 16-64'
    LIMIT 1;
  `).shift()?.value;

  return {
    percentage_benefits_claimants,
    people_in_deprived_places: 50,
  };
};

