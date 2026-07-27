import { bsToAd } from "./calendarUtils.mjs";

// Tithi names: Shukla 15 = Purnima, Krishna 15 = Amavasya
export const TITHI_NAMES_EN = [
    "Pratipada", "Dwitiya", "Tritiya", "Chaturthi", "Panchami",
    "Shashthi", "Saptami", "Ashtami", "Navami", "Dashami",
    "Ekadashi", "Dwadashi", "Trayodashi", "Chaturdashi", "Purnima",
];
export const TITHI_NAMES_KRISHNA_EN = [
    "Pratipada", "Dwitiya", "Tritiya", "Chaturthi", "Panchami",
    "Shashthi", "Saptami", "Ashtami", "Navami", "Dashami",
    "Ekadashi", "Dwadashi", "Trayodashi", "Chaturdashi", "Amavasya",
];
export const TITHI_NAMES_NP = [
    "प्रतिपदा", "द्वितीया", "तृतीया", "चतुर्थी", "पञ्चमी",
    "षष्ठी", "सप्तमी", "अष्टमी", "नवमी", "दशमी",
    "एकादशी", "द्वादशी", "त्रयोदशी", "चतुर्दशी", "पूर्णिमा",
];
export const TITHI_NAMES_KRISHNA_NP = [
    "प्रतिपदा", "द्वितीया", "तृतीया", "चतुर्थी", "पञ्चमी",
    "षष्ठी", "सप्तमी", "अष्टमी", "नवमी", "दशमी",
    "एकादशी", "द्वादशी", "त्रयोदशी", "चतुर्दशी", "अमावस्या",
];

export const PANCHANG_EVENTS = [
  { tithi: 1,  paksha: "Shukla",  month: "Ashwin",     event: "Ghatasthapana (Dashain begins)" },
  { tithi: 8,  paksha: "Shukla",  month: "Ashwin",     event: "Maha Ashtami (Dashain)" },
  { tithi: 9,  paksha: "Shukla",  month: "Ashwin",     event: "Maha Navami (Dashain)" },
  { tithi: 10, paksha: "Shukla",  month: "Ashwin",     event: "Vijaya Dashami / Tika (Dashain)" },
  { tithi: 15, paksha: "Shukla",  month: "Ashwin",     event: "Kojagrat Purnima (Dashain ends)" },

  { tithi: 13, paksha: "Krishna", month: "Kartik",     event: "Kaag Tihar (Crow Day)" },
  { tithi: 14, paksha: "Krishna", month: "Kartik",     event: "Kukur Tihar (Dog Day)" },
  { tithi: 15, paksha: "Krishna", month: "Kartik",     event: "Gai Tihar / Laxmi Puja (Cow Day / Diwali)" },
  { tithi: 1,  paksha: "Shukla",  month: "Kartik",     event: "Goru Tihar / Gobardhan Puja" },
  { tithi: 2,  paksha: "Shukla",  month: "Kartik",     event: "Bhai Tika" },
  { tithi: 6,  paksha: "Shukla",  month: "Kartik",     event: "Chhath Puja (main day)" },

  { tithi: 3,  paksha: "Shukla",  month: "Bhadrapada", event: "Haritalika Teej" },
  { tithi: 8,  paksha: "Krishna", month: "Bhadrapada", event: "Krishna Janmashtami" },
  { tithi: 4,  paksha: "Shukla",  month: "Bhadrapada", event: "Ganesh Chaturthi" },

  { tithi: 5,  paksha: "Shukla",  month: "Shravan",    event: "Naga Panchami" },
  { tithi: 15, paksha: "Shukla",  month: "Shravan",    event: "Janai Purnima / Raksha Bandhan" },

  { tithi: 14, paksha: "Krishna", month: "Phalguna",   nighttime: true, event: "Maha Shivaratri" },
  { tithi: 5,  paksha: "Shukla",  month: "Magha",      event: "Basant Panchami / Saraswati Puja" },
  { tithi: 15, paksha: "Shukla",  month: "Phalguna",   event: "Holi / Fagu Purnima" },

  { tithi: 9,  paksha: "Shukla",  month: "Chaitra",    event: "Ram Navami" },
  { tithi: 15, paksha: "Shukla",  month: "Chaitra",    event: "Hanuman Jayanti" },

  // Ekadashis — 24 per year, one per paksha per lunar month
  { tithi: 11, paksha: "Krishna", month: "Chaitra",    event: "Papamochani Ekadashi" },
  { tithi: 11, paksha: "Shukla",  month: "Chaitra",    event: "Kamada Ekadashi" },
  { tithi: 11, paksha: "Krishna", month: "Vaishakh",   event: "Varuthini Ekadashi" },
  { tithi: 11, paksha: "Shukla",  month: "Vaishakh",   event: "Mohini Ekadashi" },
  { tithi: 11, paksha: "Krishna", month: "Jyeshtha",   event: "Apara Ekadashi" },
  { tithi: 11, paksha: "Shukla",  month: "Jyeshtha",   event: "Nirjala Ekadashi" },
  { tithi: 11, paksha: "Krishna", month: "Ashadha",    event: "Yogini Ekadashi" },
  { tithi: 11, paksha: "Shukla",  month: "Ashadha",    event: "Devshayani / Harishayani Ekadashi" },
  { tithi: 11, paksha: "Krishna", month: "Shravan",    event: "Kamika Ekadashi" },
  { tithi: 11, paksha: "Shukla",  month: "Shravan",    event: "Putrada Ekadashi (Shravan)" },
  { tithi: 11, paksha: "Krishna", month: "Bhadrapada", event: "Aja / Annada Ekadashi" },
  { tithi: 11, paksha: "Shukla",  month: "Bhadrapada", event: "Parshva / Parsva Ekadashi" },
  { tithi: 11, paksha: "Krishna", month: "Ashwin",     event: "Indira Ekadashi" },
  { tithi: 11, paksha: "Shukla",  month: "Ashwin",     event: "Papankusha Ekadashi" },
  { tithi: 11, paksha: "Krishna", month: "Kartik",     event: "Rama Ekadashi" },
  { tithi: 11, paksha: "Shukla",  month: "Kartik",     event: "Prabodhini / Haribodhini / Devutthana Ekadashi" },
  { tithi: 11, paksha: "Krishna", month: "Margashirsha", event: "Utpanna Ekadashi" },
  { tithi: 11, paksha: "Shukla",  month: "Margashirsha", event: "Mokshada / Vaikuntha Ekadashi" },
  { tithi: 11, paksha: "Krishna", month: "Pausha",     event: "Saphala Ekadashi" },
  { tithi: 11, paksha: "Shukla",  month: "Pausha",     event: "Jaya / Bhaimi / Bhima Ekadashi" },
  { tithi: 11, paksha: "Krishna", month: "Magha",      event: "Shattila Ekadashi" },
  { tithi: 11, paksha: "Shukla",  month: "Phalguna",   event: "Amalaki Ekadashi" },
  { tithi: 11, paksha: "Krishna", month: "Phalguna",   event: "Vijaya Ekadashi" },
];
