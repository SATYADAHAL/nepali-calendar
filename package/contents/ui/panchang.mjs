import { julianDay, sunLongitude, moonLongitude, ayanamsa, sunrise } from "./panchang-astronomy.mjs";
import { bsToAd } from "./calendarUtils.mjs";

// Kathmandu, Nepal
const LATITUDE = 27.7172;
const LONGITUDE = 85.3240;

// Cache for panchang results keyed by "bsYear-bsMonth-bsDay"
const _panchangCache = new Map();

/**
 * Compute tithi at a given Julian Day (sunrise).
 * @param {number} jd  Julian Day (TT)
 * @returns {{ tithiGlobal: number, tithi: number, paksha: string }}
 */
function computeTithi(jd) {
    const sun = sunLongitude(jd);
    const moon = moonLongitude(jd);
    const ayan = ayanamsa(jd);
    const difference = ((moon - ayan) - (sun - ayan) + 360) % 360;
    const tithiGlobal = Math.floor(difference / 12) + 1;
    const paksha = tithiGlobal <= 15 ? "Shukla" : "Krishna";
    const tithi = tithiGlobal <= 15 ? tithiGlobal : tithiGlobal - 15;
    return { tithiGlobal, tithi, paksha };
}

/**
 * Get a cached panchang result for a given BS date.
 * @param {number} bsYear
 * @param {number} bsMonth  1-12
 * @param {number} bsDay    1-32
 * @returns {object|null}
 */
export function getCachedPanchang(bsYear, bsMonth, bsDay) {
    return _panchangCache.get(bsYear + "-" + bsMonth + "-" + bsDay) || null;
}

/**
 * Calculate tithi + paksha for a given BS date (with caching).
 * @param {number} bsYear
 * @param {number} bsMonth  1-12
 * @param {number} bsDay    1-32
 * @returns {object|null} { tithi, paksha } or null if date is out of range
 */
export function calculatePanchang(bsYear, bsMonth, bsDay) {
    const key = bsYear + "-" + bsMonth + "-" + bsDay;
    if (_panchangCache.has(key)) {
        return _panchangCache.get(key);
    }
    try {
        const ad = bsToAd(bsYear, bsMonth, bsDay);
        if (!ad || !ad.adYear) return null;

        const mm = String(ad.adMonth).padStart(2, '0');
        const dd = String(ad.adDay).padStart(2, '0');
        const todayStartNPT = new Date(`${ad.adYear}-${mm}-${dd}T00:00:00+05:45`);

        const sunriseTime = sunrise(todayStartNPT, LATITUDE, LONGITUDE);
        const jd = julianDay(sunriseTime);
        const tithi = computeTithi(jd);

        const result = { tithi: tithi.tithi, paksha: tithi.paksha };
        _panchangCache.set(key, result);
        return result;
    } catch (e) {
        return null;
    }
}
