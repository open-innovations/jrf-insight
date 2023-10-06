import {
    connection,
    run
  } from "../../../data/interim/duck.ts";

export const dwelling_stock = (place: string) => {
    return run(
        () => connection.query(`
        PIVOT(SELECT date, type_of_tenure, value FROM dwelling_stock WHERE geography_code=='${place}') ON type_of_tenure USING AVG(value);
        `)
    );
};