export const chartMax = (
  data: Record<string, number>[],
  label: string,
  config: { min?: number, round?: number }
) => {
  const { min, round } = {
    min: 0,
    round: 10,
    ...config
  };
  return Math.ceil(Math.max(min, ...data.map(x => x[label])) / round ) * round;
}

export const chartMin = (
  data: Record<string, number>[],
  label: string,
  config: { min?: number, round?: number }
) => {
  const { min, round } = {
    min: 0,
    round: 10,
    ...config
  };
  return Math.floor(Math.min(min, ...data.map(x => x[label])) / round ) * round;
}

export const dateFormatter = (x: string) => new Date(x).toLocaleDateString('en-GB', { month: 'short', year: 'numeric' });
export const dateValue = (x: string) => Date.parse(x);