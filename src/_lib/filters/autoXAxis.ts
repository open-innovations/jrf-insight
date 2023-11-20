
export function autoXAxis(
  config: Record<string, unknown>,
  data: Record<string, unknown>[],
  options: {
    xSeries?: string;
    values?: (x: unknown, i?: number) => number;
    formatter?: (x: unknown) => string;
    tickSpacing?: number;
    alignRight?: boolean;
  } = {}
) {
  const {
    xSeries, values, formatter, tickSpacing, alignRight,
  } = {
    values: (_x: unknown, i?: number) => i,
    formatter: <T>(x: T) => x,
    tickSpacing: 5,
    alignRight: true,
    ...options
  };
  if(!xSeries) throw new Error('Need to provide value of xSeries in autoXAxis');

  const xValues = data.map(x => x[xSeries!]);
  const offset = alignRight ? (xValues.length % tickSpacing) - 1 : 0;
  const ticks = Array.from(
    new Array(Math.floor(xValues.length / tickSpacing) + 1)
      .keys()
  )
    .map(x => x * tickSpacing + offset)
    .map(x => ({
      idx: x,
      value: values(xValues[x]),
      label: formatter(xValues[x])
    }));

  return {
    ...config,
    ticks,
  };
}
