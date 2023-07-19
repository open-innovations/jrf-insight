import { listAllPlaces, getPlaceDataLookup } from '../../data/interim/data.ts';

const SMALL_SITE = Deno.env.get('SMALL_SITE') !== undefined;

const smallSiteFilter = (place: string) => {
  if (!SMALL_SITE) return true;
  return ![
    'E05'
  ].includes(
    place.slice(0, 3)
  );
}

export const list = listAllPlaces().filter(smallSiteFilter);
export const lookup = getPlaceDataLookup();
