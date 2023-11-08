import { runQuery, connection } from "../../../data/interim/duck.ts";

export const happiness = (place: string) =>
  runQuery(
    () => connection.query(`
      PIVOT (
        SELECT
          Time,
          Estimate,
          v4_3
        FROM './data-mart/personal-wellbeing/wellbeing-local-authority.parquet'
        WHERE "administrative-geography"=='${place}'
        AND "MeasureOfWellbeing"=='Happiness')
        ON Estimate
        USING AVG(v4_3)
        ORDER BY Time;`)
);

export const anxiety = (place: string) =>
  runQuery(
    () => connection.query(`
      PIVOT (
        SELECT
          Time,
          Estimate,
          v4_3
        FROM './data-mart/personal-wellbeing/wellbeing-local-authority.parquet'
        WHERE "administrative-geography"=='${place}'
        AND "MeasureOfWellbeing"=='Anxiety')
        ON Estimate
        USING AVG(v4_3)
        ORDER BY Time;`)
);

export const worthwhile = (place: string) =>
  runQuery(
    () => connection.query(`
      PIVOT (
        SELECT
          Time,
          Estimate,
          v4_3
        FROM './data-mart/personal-wellbeing/wellbeing-local-authority.parquet'
        WHERE "administrative-geography"=='${place}'
        AND "MeasureOfWellbeing"=='Worthwhile')
        ON Estimate
        USING AVG(v4_3)
        ORDER BY Time;`)
);

export const life_satisfaction = (place: string) =>
  runQuery(
    () => connection.query(`
      PIVOT (
        SELECT
          Time,
          Estimate,
          v4_3
        FROM './data-mart/personal-wellbeing/wellbeing-local-authority.parquet'
        WHERE "administrative-geography"=='${place}'
        AND "MeasureOfWellbeing"=='Life satisfaction')
        ON Estimate
        USING AVG(v4_3)
        ORDER BY Time;`)
);

