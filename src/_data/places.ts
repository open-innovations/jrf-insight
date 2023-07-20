import { listAllPlaces, getPlaceDataLookup } from '../../data/interim/data.ts';

const SMALL_SITE = Deno.env.get('SMALL_SITE') !== undefined;

const removeE11 = (place: string) => !place.match(/^E11/);

export const lookup = getPlaceDataLookup();

const smallSitePivot = 'E08000035';

const smallSiteFilter = (place: string) => {
  if (!SMALL_SITE) return true;
  if (place === smallSitePivot) return true;
  if (lookup[smallSitePivot].ancestors.includes(place)) return true;
  if (lookup[place].ancestors.includes(smallSitePivot)) return true;
  return false;
}

export const list = listAllPlaces().filter(removeE11).filter(smallSiteFilter);
