import { julianDay, sunLongitude, moonLongitude, ayanamsa, sunrise, sunset } from "./panchang-astronomy.mjs";
import { bsToAd } from "./calendarUtils.mjs";
import { PANCHANG_EVENTS } from "./panchang-events.mjs";

// Kathmandu, Nepal
const LATITUDE = 27.7172;
const LONGITUDE = 85.3240;

// Lunar month names indexed by full-moon rashi
const LUNAR_MONTHS = [
    "Ashwin", "Kartik", "Margashirsha", "Pausha", "Magha", "Phalguna",
    "Chaitra", "Vaishakh", "Jyeshtha", "Ashadha", "Shravan", "Bhadrapada",
];

/**
 * Compute tithi info at a given Julian Day.
 * @param {number} jd  Julian Day (TT)
 * @returns {{ tithiGlobal: number, tithi: number, paksha: string }}
 */
function computeTithi(jd) {
    const sun = sunLongitude(jd);
    const moon = moonLongitude(jd);
    const ayan = ayanamsa(jd);
    const sunSidereal = (sun - ayan + 360) % 360;
    const moonSidereal = (moon - ayan + 360) % 360;
    const difference = (moonSidereal - sunSidereal + 360) % 360;
    const tithiGlobal = Math.floor(difference / 12) + 1;
    const paksha = tithiGlobal <= 15 ? "Shukla" : "Krishna";
    const tithi = tithiGlobal <= 15 ? tithiGlobal : tithiGlobal - 15;
    return { tithiGlobal, tithi, paksha };
}

// ===========================================================
//  Moon-phase helpers
// ===========================================================

function angDiff(testJd) {
    let d = (moonLongitude(testJd) - sunLongitude(testJd)) % 360;
    if (d < 0) d += 360;
    if (d > 180) d -= 360;
    return d;
}

function findNewMoonNear(startJd, direction) {
    let jd1 = startJd;
    let d1 = angDiff(jd1);
    for (let i = 0; i < 40; i++) {
        const jd2 = jd1 + direction * 1;
        const d2 = angDiff(jd2);
        if (Math.sign(d1) !== Math.sign(d2) && Math.abs(d2 - d1) < 180) {
            let lo = jd1, hi = jd2, dlo = d1;
            for (let j = 0; j < 50; j++) {
                const mid = (lo + hi) / 2;
                const dmid = angDiff(mid);
                if (Math.abs(dmid) < 1e-6) return mid;
                if (Math.sign(dmid) === Math.sign(dlo)) { lo = mid; dlo = dmid; }
                else { hi = mid; }
            }
            return (lo + hi) / 2;
        }
        jd1 = jd2;
        d1 = d2;
    }
    return null;
}

function rawElongation(jd) {
    return (moonLongitude(jd) - sunLongitude(jd) + 360) % 360;
}

function findFullMoonBefore(sunriseJd) {
    let eCurr = rawElongation(sunriseJd);
    let jdCurr = sunriseJd;
    for (let i = 1; i <= 30; i++) {
        const jdPrev = sunriseJd - i;
        const ePrev = rawElongation(jdPrev);
        if (ePrev < 180 && eCurr >= 180) {
            let lo = jdPrev, hi = jdCurr;
            for (let j = 0; j < 50; j++) {
                const mid = (lo + hi) / 2;
                if (rawElongation(mid) < 180) lo = mid;
                else hi = mid;
                if (hi - lo < 1e-8) break;
            }
            return (lo + hi) / 2;
        }
        jdCurr = jdPrev;
        eCurr = ePrev;
    }
    return null;
}

function siderealRashi(testJd) {
    const s = sunLongitude(testJd);
    const a = ayanamsa(testJd);
    const sSid = (s - a + 360) % 360;
    return Math.floor(sSid / 30);
}

/**
 * Calculate panchang for a given BS date.
 * @param {number} bsYear
 * @param {number} bsMonth  1-12
 * @param {number} bsDay    1-32
 * @returns {object|null} { tithi, paksha, lunarMonthIndex, isAdhikMaas, events } or null if date is out of range
 */
export function calculatePanchang(bsYear, bsMonth, bsDay) {
    try {
        const ad = bsToAd(bsYear, bsMonth, bsDay);
        if (!ad || !ad.adYear) return null;

        const mm = String(ad.adMonth).padStart(2, '0');
        const dd = String(ad.adDay).padStart(2, '0');

        // Midnight NPT for the target date
        const todayStartNPT = new Date(`${ad.adYear}-${mm}-${dd}T00:00:00+05:45`);

        // Panchang is calculated at local sunrise
        const sunriseTime = sunrise(todayStartNPT, LATITUDE, LONGITUDE);
        const jd = julianDay(sunriseTime);

        // Sunrise tithi
        const sunriseTithi = computeTithi(jd);

        // ===========================================================
        //  Lunar month — Drikpanchang Purnimanta
        // ===========================================================
        const prevNewMoon = findNewMoonNear(jd - 2, -1);
        const nextNewMoon = findNewMoonNear(jd + 2, +1);
        const lastFM = findFullMoonBefore(jd);

        let lunarMonthIndex = 0;
        if (prevNewMoon !== null) {
            const nmRashi = siderealRashi(prevNewMoon);
            const amantaDrikIdx = (nmRashi + 1) % 12;
            const amantaOurIdx = (amantaDrikIdx + 6) % 12;
            lunarMonthIndex = (lastFM !== null && lastFM > prevNewMoon)
                ? (amantaOurIdx + 1) % 12
                : amantaOurIdx;
        }

        // ===========================================================
        //  Adhik Maas detection
        // ===========================================================
        let isAdhikMaas = false;
        if (prevNewMoon !== null && nextNewMoon !== null) {
            const rashiAtPrevNM = siderealRashi(prevNewMoon);
            const rashiAtNextNM = siderealRashi(nextNewMoon);
            isAdhikMaas = rashiAtPrevNM === rashiAtNextNM;
        }

        // ===========================================================
        //  Kshaya tithi: compare today's sunrise tithi with tomorrow's
        // ===========================================================
        const todayTithiSet = [{ tithi: sunriseTithi.tithi, paksha: sunriseTithi.paksha }];

        try {
            const tomorrowStartNPT = new Date(todayStartNPT.getTime() + 24 * 60 * 60 * 1000);
            const tomorrowSunriseTime = sunrise(tomorrowStartNPT, LATITUDE, LONGITUDE);
            const tomorrowJd = julianDay(tomorrowSunriseTime);
            const tomorrowTithi = computeTithi(tomorrowJd);
            const stepsForward = (tomorrowTithi.tithiGlobal - sunriseTithi.tithiGlobal + 30) % 30;
            if (stepsForward > 1) {
                for (let i = 1; i < stepsForward; i++) {
                    const kGlobal = ((sunriseTithi.tithiGlobal - 1 + i) % 30) + 1;
                    const kPaksha = kGlobal <= 15 ? "Shukla" : "Krishna";
                    const kTithi = kGlobal <= 15 ? kGlobal : kGlobal - 15;
                    todayTithiSet.push({ tithi: kTithi, paksha: kPaksha });
                }
            }
        } catch (e) {
            // Tomorrow's sunrise failed; skip kshaya detection
        }

        // Compute sunset tithi for nighttime-specific festivals
        let sunsetTithi = sunriseTithi;
        try {
            const sunsetTime = sunset(todayStartNPT, LATITUDE, LONGITUDE);
            const sunsetJd = julianDay(sunsetTime);
            sunsetTithi = computeTithi(sunsetJd);
        } catch (e) {
            // Sunset failed; continue with sunrise tithi only
        }

        // ===========================================================
        //  Match events
        // ===========================================================
        const lunarMonthName = LUNAR_MONTHS[lunarMonthIndex];

        const events = isAdhikMaas
            ? []
            : PANCHANG_EVENTS.filter(function(e) {
                const monthMatch = e.month === lunarMonthName || e.month === null || e.month === undefined;
                if (!monthMatch) return false;

                if (e.nighttime) {
                    return e.tithi === sunsetTithi.tithi && e.paksha === sunsetTithi.paksha;
                }

                return todayTithiSet.some(function(t) {
                    return t.tithi === e.tithi && t.paksha === e.paksha;
                });
            });

        return {
            tithi: sunriseTithi.tithi,
            paksha: sunriseTithi.paksha,
            lunarMonthIndex: lunarMonthIndex,
            isAdhikMaas: isAdhikMaas,
            events: events,
        };
    } catch (e) {
        return null;
    }
}
