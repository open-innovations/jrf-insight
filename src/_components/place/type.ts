const types: Record<string, string> = {
  E05: 'Ward or Electoral Division',
  E06: 'Unitary Authority',
  E07: 'Non-Metropolitan District (two-tier)',
  E08: 'Metropolitan Borough',
  E09: 'London Borough',
  E10: 'County',
  E11: 'Metropolitan County',
  E12: 'English Region',
  E13: 'Inner and Outer London',
  E14: 'Westminster Parliamentary Constituency',
  E15: 'European Electoral Region',
  E47: 'Combined Authority'
}

export default function({ id}: { id: string }) {
  const prefix = id.slice(0, 3);
  if (prefix === 'E12' && id.slice(3, 7) === '9999') return 'Pan-region';
  return types[prefix] || `${prefix} Unknown`;
}