export default function* ({ geographies }) {
  for (const geography of geographies) {
    yield {
      url: `/place/${geography}/`,
      title: `Geography page for ${ geography }`,
      geography: geography,
    };
  }
}