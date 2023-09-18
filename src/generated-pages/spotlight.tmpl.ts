export const layout = 'templates/spotlight.njk';

export const tags = ['spotlight']

type SpotlightData = {
  name: string;
  description?: string;
  draft: boolean;
  infographics?: InfographicsConfig;
}

type InfographicsConfig = {
  defaults?: string[],
  definitions?: { key: string, [k: string]: unknown }[],
}

export default function* ({ spotlights, places, headlines }: {
  spotlights: Record<string, SpotlightData>,
  places: string[],
  headlines: unknown
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
      const infographicKeys = infographics.defaults || [];
      const headlineData = headlines[spotlight]?.getInfographicValuesForPlace(place) || {};
      const thisPlaceInfographics = infographicKeys
        .map(key => infographics.definitions?.find(x => x.key === key)!)
        .map(infographic => ({ ...infographic, value: headlineData[infographic.key]}));

      yield {
        url: `/spotlight/${spotlight}/${place}/`,
        title: name,
        display_title: `${name} spotlight`,
        spotlight: spotlight,
        description: description,
        infographics: thisPlaceInfographics,
        geography: place,
      };
    }
  }
}