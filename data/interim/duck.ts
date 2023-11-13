// To get this to work, libduckdb.so needs to be downloaded from
import { open } from "https://cdn.jsdelivr.net/gh/dringtech/duckdb@b9cb4d0/mod.ts";

const db = open(":memory:");
export const connection = db.connect();

/**
 * SETUP DATA
 */
const setupSql = await Deno.readTextFile(new URL(import.meta.resolve("./load-db.sql")).pathname);
connection.query(setupSql);

/**
 * Utility functions below
 */
function cleanup() {
  console.log("Closing duckDB!");
  connection.close();
  db.close();
}

addEventListener("unload", cleanup);

type QueryResult = Record<string, unknown>[];

export function run(query: () => QueryResult) {
  let data;
  try {
    data = query();
  } catch (e) {
    // return [];
    throw e;
  }
  return data;
}

export function runQuery(query: () => QueryResult) {
  return makeFakeCSV(run(query));
}

export function makeFakeCSV(rows: QueryResult) {
  if (rows.length === 0) {
    return {
      names: [],
      rows,
    };
  }
  const names = Object.keys(rows[0]);
  return {
    names,
    rows,
  };
}

export const arrayToDuckSet = (a: string[]) => `(${a.map(e => `'${e}'`).join(',')})`