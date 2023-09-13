import { getHousePrices } from '../../../../../data/interim/duck.ts';

export const house_prices = getHousePrices();

export {
  getHousePricesForPlace as house_prices_for_place,
} from '../../../../../data/interim/duck.ts';
