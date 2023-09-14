export const layout = 'templates/spotlight.njk';

export const tags = ['spotlight']

type SpotlightData = {
  name: string;
  description?: string;
  draft: boolean;
  infographics?: { title: string };
}

export default function* ({ spotlights, places }: {
  spotlights: Record<string, SpotlightData>,
  places: string[],
}) {
  for (const [spotlight, spotlightData] of Object.entries(spotlights)) {
    if (spotlightData.draft === true) {
      continue;
    }
    const { name, description, infographics = {} } = spotlightData;
    yield {
      url: `/spotlight/${spotlight}/`,
      tags: ['main'],
      title: name,
      display_title: `${name} spotlight`,
      spotlight: spotlight,
      description: description,
      layout: 'templates/redirect.njk',
      target: `/spotlight/${spotlight}/E12999901/`,
    };
    
    for (const place of places.list) {
      yield {
        url: `/spotlight/${spotlight}/${place}/`,
        title: name,
        display_title: `${name} spotlight`,
        spotlight: spotlight,
        description: description,
        infographics,
        geography: place,
      };
    }
  }
}