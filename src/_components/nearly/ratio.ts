import { ratioed, readableDirection } from "https://github.com/dringtech/nearly/raw/main/src/lib.ts";

export default function(context: { value: number, withDirection: boolean }) {
  const { value, withDirection = false } = context;
  const ratio = ratioed(value, { maxDenominator: 20 });
  if (!ratio) return `ERROR calculating ratio for ${value}`;
  
  const output = `${
        withDirection ? readableDirection(ratio.difference) + ' ' : ''
      }${
        ratio.numerator
      } in ${
        ratio.denominator
      }`;
  return output;
}