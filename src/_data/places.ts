import { listAllPlaces, getPlaceDataLookup } from '../../data/interim/data.ts';

const SMALL_SITE = Deno.env.get('SMALL_SITE') !== undefined;

const removeE11 = (place: string) => !place.match(/^E11/);

const smallSiteFilter = (place: string) => {
  if (!SMALL_SITE) return true;
  return ![
    'E05'
  ].includes(
    place.slice(0, 3)
  );
}

export const list = listAllPlaces().filter(removeE11).filter(smallSiteFilter);
export const lookup = getPlaceDataLookup();
