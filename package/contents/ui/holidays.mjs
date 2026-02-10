// Holidays data for Nepali Calendar
//
// ARCHITECTURE:
// 1. CONSTANT_HOLIDAYS_BS: Fixed BS dates that repeat every year (e.g., Baisakh 1, Falgun 7)
//    - To add: Add an entry with month, day, title, and description
//    - These automatically apply to all years
//
// 2. CONSTANT_HOLIDAYS_AD: Fixed AD dates that repeat every year (e.g., Christmas - Dec 25)
//    - To add: Add an entry with month (1-12), day, title, and description
//    - These are converted to BS dates dynamically each year
//
// 3. HOLIDAYS_XXXX: Year-specific holidays that may vary (e.g., Dashain, Tihar, Buddha Jayanti)
//    - Create a new HOLIDAYS_XXXX object for each year
//    - Include nationwide_holidays and targeted_holidays arrays
//    - Format: "date": "YYYY-MM-DD" (e.g., "2080-05-14")
//    - For multi-day holidays, use "date": "YYYY-MM-DD to YYYY-MM-DD"
//
// 4. ALL_HOLIDAYS: Combined data from all year-specific holidays
//    - Update this when adding a new year's holiday data
//
// HOW TO ADD NEW HOLIDAYS:
// - For constant BS holidays: Add to CONSTANT_HOLIDAYS_BS array below
//   - Optional: Add "fromYear" field (BS year) if holiday only applies from a certain year onwards
// - For constant AD holidays: Add to CONSTANT_HOLIDAYS_AD array below
//   - Optional: Add "fromYear" field (BS year) if holiday only applies from a certain year onwards
// - For year-specific: Create/update HOLIDAYS_XXXX object and add to ALL_HOLIDAYS
// - Multiple holidays on same date will be shown together in tooltip

// Constant holidays that repeat every year on fixed BS dates
export const CONSTANT_HOLIDAYS_BS = [
  {
    month: 1,
    day: 1,
    title: 'Naya Barsha (New Year)',
    description: 'Baisakh 1 - Nepali New Year, nationwide public holiday.',
  },
  {
    month: 2,
    day: 15,
    title: 'Ganatantra Diwas (Republic Day)',
    titleDevnagari: 'गणतन्त्र दिवस',
    description: 'Jestha 15 - Republic Day, nationwide public holiday.',
    fromYear: 2065, // BS
  },
  {
    month: 6,
    day: 3,
    title: 'Constitution Day',
    titleDevnagari: 'संविधान दिवस',
    description: 'Ashoj 3 - Constitution Day, nationwide public holiday.',
    fromYear: 2072,
  },
  {
    month: 9,
    day: 15,
    title: 'Tamu Loshar',
    titleDevnagari: 'तमु ल्होसार',
    description: 'Poush 15 - Gurung (Tamu) New Year festival.',
    fromYear: null,
  },
  {
    month: 9,
    day: 27,
    title: 'Prithvi Jayanti (National Unity Day)',
    titleDevnagari: 'पृथ्वी जयन्ती तथा राष्ट्रिय एकता दिवस',
    description: 'Poush 27 - Birth anniversary of Prithvi Narayan Shah.',
    fromYear: 2000,
  },
  {
    month: 10,
    day: 1,
    title: 'Maghe Sankranti',
    titleDevnagari: 'माघे सङ्क्रान्ति',
    description: 'Magh 1 - Traditional solar festival, nationwide holiday.',
    fromYear: null,
  },
  {
    month: 10,
    day: 16,
    title: "Martyrs' Day",
    titleDevnagari: 'शहीद दिवस',
    description: 'Magh 16 - Remembering the first four martyrs of Nepal.',
    fromYear: 2007,
  },
  {
    month: 11,
    day: 7,
    title: 'National Democracy Day',
    titleDevnagari: 'राष्ट्रिय प्रजातन्त्र दिवस',
    description: 'Falgun 7 - Establishment of democracy in Nepal.',
    fromYear: 2007,
  },
];

export const CONSTANT_HOLIDAYS_AD = [
  {
    month: 12,
    day: 25,
    title: 'Christmas Day',
    titleDevnagari: 'क्रिसमस दिवस',
    description: 'December 25 - Nationwide public holiday for Christians.',
  },
];

export const ALL_HOLIDAYS = {
  nationwide_holidays: [],
  targeted_holidays: [],
};
