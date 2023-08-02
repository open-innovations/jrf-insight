// To get this to work, libduckdb.so needs to be downloaded from 
import { open } from "https://cdn.jsdelivr.net/gh/dringtech/duckdb@b9cb4d0/mod.ts";

const db = open(':memory:');
const connection = db.connect();

// Setup data
connection.query("CREATE TABLE current_rental_prices AS SELECT * FROM './data/interim/current_rental_prices.csv'");
connection.query("CREATE TABLE house_prices AS SELECT * FROM './data/interim/house_prices.csv'");

function fakeCSVLoader(query: string) {
  const rows = connection.query(query);
  const names = Object.keys(rows[0]);
  return {
    names,
    rows,
  }
}

// Access functions
export function getRentalPrices() {
  return fakeCSVLoader('SELECT * FROM current_rental_prices');
}

export function getHousePrices() {
  return fakeCSVLoader('SELECT * FROM house_prices');
}

function cleanup() {
  console.log('Closing duckDB!');
  connection.close();
  db.close();
}

addEventListener("unload", cleanup);
