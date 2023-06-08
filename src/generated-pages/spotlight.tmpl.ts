export default function* ({ spotlights, geographies }) {
  for (const spotlight of spotlights) {
    yield {
      url: `/spotlight/${spotlight}/`,
      title: `Spotlight page for ${spotlight}`,
      spotlight: spotlight,
    };

    for (const geography of geographies) {
      yield {
        url: `/spotlight/${spotlight}/${geography}/`,
        title: `Spotlight page for ${spotlight} at ${geography} scale`,
        spotlight: spotlight,
        geography: geography,
      };
    }
  }
}