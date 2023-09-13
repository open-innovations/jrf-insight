import { getRentalPrices, getCurrentRentalPricesForPlace } from '../../../../../data/interim/duck.ts';
export const current_rental_prices = getRentalPrices();

export const current_rental_prices_for_place = getCurrentRentalPricesForPlace;
