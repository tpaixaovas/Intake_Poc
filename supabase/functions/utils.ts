// utils.ts
export function priceWithDiscount(price: number | null, discount: number | null): number | null {
    if (price === null || discount === null) {
      return null;
    }
    const priceWithDiscount = price - (price * discount);
    return roundToDecimalPlace(priceWithDiscount,2)
  }

  export function roundToDecimalPlace(number: number, decimalPlaces: number): number {
    const factor = Math.pow(10, decimalPlaces);
    return Math.round(number * factor) / factor;
}