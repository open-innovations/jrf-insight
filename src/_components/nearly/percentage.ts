export default function (context: { value: number }) {
  const { value } = context;
  return (value * 100).toFixed(0) + '%';
}