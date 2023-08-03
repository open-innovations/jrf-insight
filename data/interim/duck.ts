// To get this to work, libduckdb.so needs to be downloaded from 
import { open } from "https://cdn.jsdelivr.net/gh/dringtech/duckdb@b9cb4d0/mod.ts";

const db = open(':memory:');
const connection = db.connect();

// Setup data
connection.query("CREATE TABLE current_rental_prices AS SELECT * FROM './data/interim/current_rental_prices.csv'");
connection.query("CREATE TABLE house_prices AS SELECT * FROM read_csv_auto('./data/interim/house_prices.csv')");

function makeFakeCSV(rows: Record<string, unknown>[]) {
  const names = Object.keys(rows[0]);
  return {
    names,
    rows,
  }
}

function fakeCSVLoader(query: string) {
  const rows = connection.query(query);
  return makeFakeCSV(rows);
}

// Access functions
export function getRentalPrices() {
  return fakeCSVLoader('SELECT * FROM current_rental_prices');
}


export function getCurrentRentalPricesForPlace(place: string) {
  const currentRentalPricesForPlace = connection.prepare('SELECT property_code, COLUMNS(?::VARCHAR) FROM current_rental_prices');
  try {
    const data = currentRentalPricesForPlace.query(place)
    return makeFakeCSV(data);
  } catch(e) {
    console.error(e);
    return {
      rows: [],
      names: [],
    }
  }
}

export function getHousePrices() {
  return fakeCSVLoader('SELECT * FROM house_prices');
}

export function getHousePricesForPlace(place: string) {
  const query = `SELECT date, ${place} FROM house_prices`;
  try {
    const data = connection.query(query).map(({ date, ...rest }) => ({
      date: new Date(date).toISOString().split('T').shift(),
      ...rest,
    }));
    return makeFakeCSV(data);
  } catch(e) {
    console.error(e);
    return {
      rows: [],
      names: [],
    }
  }
}

function cleanup() {
  console.log('Closing duckDB!');
  connection.close();
  db.close();
}

addEventListener("unload", cleanup);
