/**
 * Hindu Panchang Astronomy
 * Extracted from Astronomy Engine (MIT License)
 * Original: https://github.com/cosinekitty/astronomy
 *
 * Provides: julianDay, sunLongitude, moonLongitude, ayanamsa, sunrise
 * Zero dependencies. ES module.
 */

// ===========================================================
//  Constants
// ===========================================================

const PI2         = 2 * Math.PI;
const DEG2RAD     = 0.017453292519943296;
const RAD2DEG     = 57.295779513082321;
const HOUR2RAD    = 0.2617993877991494365;
const RAD2HOUR    = 3.819718634205488;
const ASEC2RAD    = 4.848136811095359935899141e-6;
const ARC         = 3600 * (180 / Math.PI);
const ASEC180     = 180 * 3600;
const ASEC360     = 2 * ASEC180;
const KM_PER_AU   = 1.4959787069098932e+8;
const C_AUDAY     = 173.1446326846693;
const SECONDS_PER_DAY = 86400;
const MILLIS_PER_DAY  = SECONDS_PER_DAY * 1000;
const DAYS_PER_TROPICAL_YEAR = 365.24217;
const DAYS_PER_MILLENNIUM = 365250;
const ANGVEL      = 7.2921150e-5;
const MEAN_SYNODIC_MONTH = 29.530588;
const EARTH_FLATTENING = 0.996647180302104;
const EARTH_FLATTENING_SQUARED = EARTH_FLATTENING * EARTH_FLATTENING;
const EARTH_EQUATORIAL_RADIUS_KM = 6378.1366;
const EARTH_EQUATORIAL_RADIUS_AU = EARTH_EQUATORIAL_RADIUS_KM / KM_PER_AU;
const SUN_RADIUS_KM = 695700.0;
const SUN_RADIUS_AU = SUN_RADIUS_KM / KM_PER_AU;
const MOON_EQUATORIAL_RADIUS_KM = 1738.1;
const MOON_EQUATORIAL_RADIUS_AU = MOON_EQUATORIAL_RADIUS_KM / KM_PER_AU;
const REFRACTION_NEAR_HORIZON = 34 / 60;
const SOLAR_DAYS_PER_SIDEREAL_DAY = 0.9972695717592592;
const J2000 = new Date('2000-01-01T12:00:00Z');

const LON_INDEX = 0;
const LAT_INDEX = 1;
const RAD_INDEX = 2;

const BODY_SUN = 'Sun';
const BODY_MOON = 'Moon';

// ===========================================================
//  Utility helpers
// ===========================================================

function frac(x) {
    return x - Math.floor(x);
}

function clampAngle(x) {
    x = x % PI2;
    if (x < 0) x += PI2;
    return x;
}

// ===========================================================
//  Internal time representation
//  { ut: days since J2000 (UT), tt: days since J2000 (TT) }
// ===========================================================

function deltaT_EspenakMeeus(ut) {
    const y = 2000 + ((ut - 14) / DAYS_PER_TROPICAL_YEAR);
    let u, u2, u3, u4, u5, u6, u7;

    if (y < -500) {
        u = (y - 1820) / 100;
        return -20 + (32 * u * u);
    }
    if (y < 500) {
        u = y / 100;
        u2 = u * u; u3 = u * u2; u4 = u2 * u2; u5 = u2 * u3; u6 = u3 * u3;
        return 10583.6 - 1014.41 * u + 33.78311 * u2 - 5.952053 * u3
             - 0.1798452 * u4 + 0.022174192 * u5 + 0.0090316521 * u6;
    }
    if (y < 1600) {
        u = (y - 1000) / 100;
        u2 = u * u; u3 = u * u2; u4 = u2 * u2; u5 = u2 * u3; u6 = u3 * u3;
        return 1574.2 - 556.01 * u + 71.23472 * u2 + 0.319781 * u3
             - 0.8503463 * u4 - 0.005050998 * u5 + 0.0083572073 * u6;
    }
    if (y < 1700) {
        u = y - 1600;
        u2 = u * u; u3 = u * u2;
        return 120 - 0.9808 * u - 0.01532 * u2 + u3 / 7129.0;
    }
    if (y < 1800) {
        u = y - 1700;
        u2 = u * u; u3 = u * u2; u4 = u2 * u2;
        return 8.83 + 0.1603 * u - 0.0059285 * u2 + 0.00013336 * u3 - u4 / 1174000;
    }
    if (y < 1860) {
        u = y - 1800;
        u2 = u * u; u3 = u * u2; u4 = u2 * u2; u5 = u2 * u3; u6 = u3 * u3; u7 = u3 * u4;
        return 13.72 - 0.332447 * u + 0.0068612 * u2 + 0.0041116 * u3
             - 0.00037436 * u4 + 0.0000121272 * u5 - 0.0000001699 * u6
             + 0.000000000875 * u7;
    }
    if (y < 1900) {
        u = y - 1860;
        u2 = u * u; u3 = u * u2; u4 = u2 * u2; u5 = u2 * u3;
        return 7.62 + 0.5737 * u - 0.251754 * u2 + 0.01680668 * u3
             - 0.0004473624 * u4 + u5 / 233174;
    }
    if (y < 1920) {
        u = y - 1900;
        u2 = u * u; u3 = u * u2; u4 = u2 * u2;
        return -2.79 + 1.494119 * u - 0.0598939 * u2 + 0.0061966 * u3 - 0.000197 * u4;
    }
    if (y < 1941) {
        u = y - 1920;
        u2 = u * u; u3 = u * u2;
        return 21.20 + 0.84493 * u - 0.076100 * u2 + 0.0020936 * u3;
    }
    if (y < 1961) {
        u = y - 1950;
        u2 = u * u; u3 = u * u2;
        return 29.07 + 0.407 * u - u2 / 233 + u3 / 2547;
    }
    if (y < 1986) {
        u = y - 1975;
        u2 = u * u; u3 = u * u2;
        return 45.45 + 1.067 * u - u2 / 260 - u3 / 718;
    }
    if (y < 2005) {
        u = y - 2000;
        u2 = u * u; u3 = u * u2; u4 = u2 * u2; u5 = u2 * u3;
        return 63.86 + 0.3345 * u - 0.060374 * u2 + 0.0017275 * u3
             + 0.000651814 * u4 + 0.00002373599 * u5;
    }
    if (y < 2050) {
        u = y - 2000;
        return 62.92 + 0.32217 * u + 0.005589 * u * u;
    }
    if (y < 2150) {
        u = (y - 1820) / 100;
        return -20 + 32 * u * u - 0.5628 * (2150 - y);
    }
    u = (y - 1820) / 100;
    return -20 + (32 * u * u);
}

function terrestrialTime(ut) {
    return ut + deltaT_EspenakMeeus(ut) / SECONDS_PER_DAY;
}

function dateToTime(date) {
    const ut = (date.getTime() - J2000.getTime()) / MILLIS_PER_DAY;
    return { ut, tt: terrestrialTime(ut) };
}

function jdToTime(jd) {
    const ut = jd - 2451545.0;
    return { ut, tt: terrestrialTime(ut) };
}

function addDays(time, days) {
    const ut = time.ut + days;
    return { ut, tt: terrestrialTime(ut) };
}

// ===========================================================
//  Nutation – IAU 2000B
// ===========================================================

function iau2000b(time) {
    function mod(x) {
        return (x % ASEC360) * ASEC2RAD;
    }

    const t = time.tt / 36525;
    const elp = mod(1287104.79305 + t * 129596581.0481);
    const f   = mod(335779.526232 + t * 1739527262.8478);
    const d   = mod(1072260.70369 + t * 1602961601.2090);
    const om  = mod(450160.398036 - t * 6962890.5431);

    let sarg = Math.sin(om);
    let carg = Math.cos(om);
    let dp = (-172064161.0 - 174666.0 * t) * sarg + 33386.0 * carg;
    let de = (92052331.0 + 9086.0 * t) * carg + 15377.0 * sarg;

    let arg = 2.0 * (f - d + om);
    sarg = Math.sin(arg);
    carg = Math.cos(arg);
    dp += (-13170906.0 - 1675.0 * t) * sarg - 13696.0 * carg;
    de += (5730336.0 - 3015.0 * t) * carg - 4587.0 * sarg;

    arg = 2.0 * (f + om);
    sarg = Math.sin(arg);
    carg = Math.cos(arg);
    dp += (-2276413.0 - 234.0 * t) * sarg + 2796.0 * carg;
    de += (978459.0 - 485.0 * t) * carg + 1374.0 * sarg;

    arg = 2.0 * om;
    sarg = Math.sin(arg);
    carg = Math.cos(arg);
    dp += (2074554.0 + 207.0 * t) * sarg - 698.0 * carg;
    de += (-897492.0 + 470.0 * t) * carg - 291.0 * sarg;

    sarg = Math.sin(elp);
    carg = Math.cos(elp);
    dp += (1475877.0 - 3633.0 * t) * sarg + 11817.0 * carg;
    de += (73871.0 - 184.0 * t) * carg - 1924.0 * sarg;

    return {
        dpsi: -0.000135 + (dp * 1.0e-7),
        deps: +0.000388 + (de * 1.0e-7)
    };
}

function meanObliquity(time) {
    const t = time.tt / 36525;
    const asec = (
        (((( -0.0000000434 * t
           - 0.000000576) * t
           + 0.00200340) * t
           - 0.0001831) * t
           - 46.836769) * t + 84381.406
    );
    return asec / 3600.0;
}

let _cache_e_tilt = null;

function e_tilt(time) {
    if (!_cache_e_tilt || Math.abs(_cache_e_tilt.tt - time.tt) > 1.0e-6) {
        const nut = iau2000b(time);
        const mobl = meanObliquity(time);
        const tobl = mobl + (nut.deps / 3600);
        _cache_e_tilt = {
            tt: time.tt,
            dpsi: nut.dpsi,
            deps: nut.deps,
            ee: nut.dpsi * Math.cos(mobl * DEG2RAD) / 15,
            mobl,
            tobl
        };
    }
    return _cache_e_tilt;
}

// ===========================================================
//  Rotation helpers
// ===========================================================

function rotateMatrix(rot, vec) {
    return [
        rot[0][0] * vec[0] + rot[1][0] * vec[1] + rot[2][0] * vec[2],
        rot[0][1] * vec[0] + rot[1][1] * vec[1] + rot[2][1] * vec[2],
        rot[0][2] * vec[0] + rot[1][2] * vec[1] + rot[2][2] * vec[2]
    ];
}

// ===========================================================
//  Nutation rotation
// ===========================================================

function nutation_rot(time, fromJ2000) {
    const tilt = e_tilt(time);
    const oblm = tilt.mobl * DEG2RAD;
    const oblt = tilt.tobl * DEG2RAD;
    const psi  = tilt.dpsi * ASEC2RAD;
    const cobm = Math.cos(oblm), sobm = Math.sin(oblm);
    const cobt = Math.cos(oblt), sobt = Math.sin(oblt);
    const cpsi = Math.cos(psi),  spsi = Math.sin(psi);

    const xx =  cpsi;
    const yx = -spsi * cobm;
    const zx = -spsi * sobm;
    const xy =  spsi * cobt;
    const yy =  cpsi * cobm * cobt + sobm * sobt;
    const zy =  cpsi * sobm * cobt - cobm * sobt;
    const xz =  spsi * sobt;
    const yz =  cpsi * cobm * sobt - sobm * cobt;
    const zz =  cpsi * sobm * sobt + cobm * cobt;

    if (fromJ2000) {
        return [[xx, xy, xz], [yx, yy, yz], [zx, zy, zz]];
    }
    return [[xx, yx, zx], [xy, yy, zy], [xz, yz, zz]];
}

function nutationVec(pos, time, fromJ2000) {
    return rotateMatrix(nutation_rot(time, fromJ2000), pos);
}

// ===========================================================
//  Precession rotation
// ===========================================================

function precession_rot(time, fromJ2000) {
    const t = time.tt / 36525;
    let eps0 = 84381.406;

    let psia = (((((-0.0000000951 * t
        + 0.000132851) * t
        - 0.00114045) * t
        - 1.0790069) * t
        + 5038.481507) * t);

    let omegaa = (((((+0.0000003337 * t
        - 0.000000467) * t
        - 0.00772503) * t
        + 0.0512623) * t
        - 0.025754) * t + eps0);

    let chia = (((((-0.0000000560 * t
        + 0.000170663) * t
        - 0.00121197) * t
        - 2.3814292) * t
        + 10.556403) * t);

    eps0   *= ASEC2RAD;
    psia   *= ASEC2RAD;
    omegaa *= ASEC2RAD;
    chia   *= ASEC2RAD;

    const sa = Math.sin(eps0), ca = Math.cos(eps0);
    const sb = Math.sin(-psia), cb = Math.cos(-psia);
    const sc = Math.sin(-omegaa), cc = Math.cos(-omegaa);
    const sd = Math.sin(chia), cd = Math.cos(chia);

    const xx =  cd * cb - sb * sd * cc;
    const yx =  cd * sb * ca + sd * cc * cb * ca - sa * sd * sc;
    const zx =  cd * sb * sa + sd * cc * cb * sa + ca * sd * sc;
    const xy = -sd * cb - sb * cd * cc;
    const yy = -sd * sb * ca + cd * cc * cb * ca - sa * cd * sc;
    const zy = -sd * sb * sa + cd * cc * cb * sa + ca * cd * sc;
    const xz =  sb * sc;
    const yz = -sc * cb * ca - sa * cc;
    const zz = -sc * cb * sa + cc * ca;

    if (fromJ2000) {
        return [[xx, xy, xz], [yx, yy, yz], [zx, zy, zz]];
    }
    return [[xx, yx, zx], [xy, yy, zy], [xz, yz, zz]];
}

function precessionVec(pos, time, fromJ2000) {
    return rotateMatrix(precession_rot(time, fromJ2000), pos);
}

/**
 * Combined nutation + precession (or reverse depending on direction).
 * fromJ2000 = true  => convert J2000 -> date
 * fromJ2000 = false => convert date -> J2000
 */
function gyration(pos, time, fromJ2000) {
    if (fromJ2000) {
        return nutationVec(precessionVec(pos, time, true), time, true);
    }
    return precessionVec(nutationVec(pos, time, false), time, false);
}

// ===========================================================
//  Obl ecliptic -> equatorial conversion
// ===========================================================

function oblEcl2Equ(oblDeg, pos) {
    const obl = oblDeg * DEG2RAD;
    const c = Math.cos(obl), s = Math.sin(obl);
    return [
        pos[0],
        pos[1] * c - pos[2] * s,
        pos[1] * s + pos[2] * c
    ];
}

// ===========================================================
//  Equatorial -> ecliptic conversion
// ===========================================================

function rotateEquatorialToEcliptic(ex, ey, ez, cosOb, sinOb) {
    const eclY = ey * cosOb + ez * sinOb;
    const eclZ = -ey * sinOb + ez * cosOb;
    const xyproj = Math.hypot(ex, eclY);
    let elon = 0;
    if (xyproj > 0) {
        elon = RAD2DEG * Math.atan2(eclY, ex);
        if (elon < 0) elon += 360;
    }
    const elat = RAD2DEG * Math.atan2(eclZ, xyproj);
    return { elat, elon };
}

// ===========================================================
//  VSOP87 — Earth only
// ===========================================================

const vsopEarth = [
    // Longitude
    [
        [
            [1.75347045673, 0.00000000000, 0.00000000000],
            [0.03341656453, 4.66925680415, 6283.07584999140],
            [0.00034894275, 4.62610242189, 12566.15169998280],
            [0.00003417572, 2.82886579754, 3.52311834900],
            [0.00003497056, 2.74411783405, 5753.38488489680],
            [0.00003135899, 3.62767041756, 77713.77146812050],
            [0.00002676218, 4.41808345438, 7860.41939243920],
            [0.00002342691, 6.13516214446, 3930.20969621960],
            [0.00001273165, 2.03709657878, 529.69096509460],
            [0.00001324294, 0.74246341673, 11506.76976979360],
            [0.00000901854, 2.04505446477, 26.29831979980],
            [0.00001199167, 1.10962946234, 1577.34354244780],
            [0.00000857223, 3.50849152283, 398.14900340820],
            [0.00000779786, 1.17882681962, 5223.69391980220],
            [0.00000990250, 5.23268072088, 5884.92684658320],
            [0.00000753141, 2.53339052847, 5507.55323866740],
            [0.00000505267, 4.58292599973, 18849.22754997420],
            [0.00000492392, 4.20505711826, 775.52261132400],
            [0.00000356672, 2.91954114478, 0.06731030280],
            [0.00000284125, 1.89869240932, 796.29800681640],
            [0.00000242879, 0.34481445893, 5486.77784317500],
            [0.00000317087, 5.84901948512, 11790.62908865880],
            [0.00000271112, 0.31486255375, 10977.07880469900],
            [0.00000206217, 4.80646631478, 2544.31441988340],
            [0.00000205478, 1.86953770281, 5573.14280143310],
            [0.00000202318, 2.45767790232, 6069.77675455340],
            [0.00000126225, 1.08295459501, 20.77539549240],
            [0.00000155516, 0.83306084617, 213.29909543800]
        ],
        [
            [6283.07584999140, 0.00000000000, 0.00000000000],
            [0.00206058863, 2.67823455808, 6283.07584999140],
            [0.00004303419, 2.63512233481, 12566.15169998280]
        ],
        [
            [0.00008721859, 1.07253635559, 6283.07584999140]
        ]
    ],
    // Latitude
    [
        [],
        [
            [0.00227777722, 3.41376620530, 6283.07584999140],
            [0.00003805678, 3.37063423795, 12566.15169998280]
        ]
    ],
    // Radius
    [
        [
            [1.00013988784, 0.00000000000, 0.00000000000],
            [0.01670699632, 3.09846350258, 6283.07584999140],
            [0.00013956024, 3.05524609456, 12566.15169998280],
            [0.00003083720, 5.19846674381, 77713.77146812050],
            [0.00001628463, 1.17387558054, 5753.38488489680],
            [0.00001575572, 2.84685214877, 7860.41939243920],
            [0.00000924799, 5.45292236722, 11506.76976979360],
            [0.00000542439, 4.56409151453, 3930.20969621960],
            [0.00000472110, 3.66100022149, 5884.92684658320],
            [0.00000085831, 1.27079125277, 161000.68573767410],
            [0.00000057056, 2.01374292245, 83996.84731811189],
            [0.00000055736, 5.24159799170, 71430.69561812909],
            [0.00000174844, 3.01193636733, 18849.22754997420],
            [0.00000243181, 4.27349530790, 11790.62908865880]
        ],
        [
            [0.00103018607, 1.10748968172, 6283.07584999140],
            [0.00001721238, 1.06442300386, 12566.15169998280]
        ],
        [
            [0.00004359385, 5.78455133808, 6283.07584999140]
        ]
    ]
];

function vsopFormula(formula, t, clampAngle) {
    let tpower = 1;
    let coord = 0;
    for (const series of formula) {
        let sum = 0;
        for (const [ampl, phas, freq] of series) {
            sum += ampl * Math.cos(phas + t * freq);
        }
        let incr = tpower * sum;
        if (clampAngle) incr %= PI2;
        coord += incr;
        tpower *= t;
    }
    return coord;
}

function vsopSphereToRect(lon, lat, radius) {
    const rCosLat = radius * Math.cos(lat);
    return [
        rCosLat * Math.cos(lon),
        rCosLat * Math.sin(lon),
        radius * Math.sin(lat)
    ];
}

function vsopRotate(eclip) {
    return [
        eclip[0] + 0.000000440360 * eclip[1] - 0.000000190919 * eclip[2],
        -0.000000479966 * eclip[0] + 0.917482137087 * eclip[1] - 0.397776982902 * eclip[2],
        0.397776982902 * eclip[1] + 0.917482137087 * eclip[2]
    ];
}

function calcVsop(time) {
    const t = time.tt / DAYS_PER_MILLENNIUM;
    const lon = vsopFormula(vsopEarth[LON_INDEX], t, true);
    const lat = vsopFormula(vsopEarth[LAT_INDEX], t, false);
    const rad = vsopFormula(vsopEarth[RAD_INDEX], t, false);
    const eclip = vsopSphereToRect(lon, lat, rad);
    return vsopRotate(eclip);
}

// ===========================================================
//  Sun longitude (geocentric ecliptic)
// ===========================================================

function sunLongitude(jd) {
    const time = jdToTime(jd);
    // Correct for light-travel time
    const sunTime = addDays(time, -1 / C_AUDAY);
    const earth = calcVsop(sunTime);
    const sun = [-earth[0], -earth[1], -earth[2]];
    const [gx, gy, gz] = gyration(sun, sunTime, true);
    const tilt = e_tilt(sunTime);
    const cosOb = Math.cos(tilt.tobl * DEG2RAD);
    const sinOb = Math.sin(tilt.tobl * DEG2RAD);
    return rotateEquatorialToEcliptic(gx, gy, gz, cosOb, sinOb).elon;
}

// ===========================================================
//  Moon longitude (ELP2000-style trigonometric series)
// ===========================================================

function calcMoon(time) {
    const T = time.tt / 36525;
    const T2 = T * T;

    // Pascal-style 2D arrays for harmonic terms
    const coMin = -6, coMax = 6, siMin = 1, siMax = 4;
    const coArr = [];
    const siArr = [];
    for (let i = 0; i <= coMax - coMin; i++) {
        coArr.push(new Float64Array(siMax - siMin + 1));
        siArr.push(new Float64Array(siMax - siMin + 1));
    }
    function CO(x, y) { return coArr[x - coMin][y - siMin]; }
    function SI(x, y) { return siArr[x - coMin][y - siMin]; }
    function setCO(x, y, v) { coArr[x - coMin][y - siMin] = v; }
    function setSI(x, y, v) { siArr[x - coMin][y - siMin] = v; }

    function addThe(c1, s1, c2, s2, func) {
        func(c1 * c2 - s1 * s2, s1 * c2 + c1 * s2);
    }

    function Sine(phi) {
        return Math.sin(PI2 * phi);
    }

    let DLAM = 0, DS = 0, GAM1C = 0, SINPI = 3422.7000;
    let DGAM, L0, L, LS, F, D, DL0, DL, DLS, DF, DD;
    let N;

    const S1 = Sine(0.19833 + 0.05611 * T);
    const S2 = Sine(0.27869 + 0.04508 * T);
    const S3 = Sine(0.16827 - 0.36903 * T);
    const S4 = Sine(0.34734 - 5.37261 * T);
    const S5 = Sine(0.10498 - 5.37899 * T);
    const S6 = Sine(0.42681 - 0.41855 * T);
    const S7 = Sine(0.14943 - 5.37511 * T);

    DL0 = 0.84 * S1 + 0.31 * S2 + 14.27 * S3 + 7.26 * S4 + 0.28 * S5 + 0.24 * S6;
    DL  = 2.94 * S1 + 0.31 * S2 + 14.27 * S3 + 9.34 * S4 + 1.12 * S5 + 0.83 * S6;
    DLS = -6.40 * S1 - 1.89 * S6;
    DF  = 0.21 * S1 + 0.31 * S2 + 14.27 * S3 - 88.70 * S4 - 15.30 * S5 + 0.24 * S6 - 1.86 * S7;
    DD  = DL0 - DLS;
    DGAM = (-3332e-9 * Sine(0.59734 - 5.37261 * T)
           - 539e-9 * Sine(0.35498 - 5.37899 * T)
            - 64e-9 * Sine(0.39943 - 5.37511 * T));

    L0 = PI2 * frac(0.60643382 + 1336.85522467 * T - 0.00000313 * T2) + DL0 / ARC;
    L  = PI2 * frac(0.37489701 + 1325.55240982 * T + 0.00002565 * T2) + DL / ARC;
    LS = PI2 * frac(0.99312619 + 99.99735956 * T - 0.00000044 * T2) + DLS / ARC;
    F  = PI2 * frac(0.25909118 + 1342.22782980 * T - 0.00000892 * T2) + DF / ARC;
    D  = PI2 * frac(0.82736186 + 1236.85308708 * T - 0.00000397 * T2) + DD / ARC;

    // Build harmonic tables for L, LS, F, D
    const args = [null, L, LS, F, D];
    const maxPowers = [null, 4, 3, 4, 6];
    const facs = [null, 1.000002208, 0.997504612 - 0.002495388 * T, 1.000002708 + 139.978 * DGAM, 1.0];

    for (let I = 1; I <= 4; I++) {
        const ARG = args[I];
        const MAX = maxPowers[I];
        const FAC = facs[I];
        setCO(0, I, 1);
        setCO(1, I, Math.cos(ARG) * FAC);
        setSI(0, I, 0);
        setSI(1, I, Math.sin(ARG) * FAC);
        for (let J = 2; J <= MAX; J++) {
            addThe(CO(J - 1, I), SI(J - 1, I), CO(1, I), SI(1, I), (c, s) => { setCO(J, I, c); setSI(J, I, s); });
        }
        for (let J = 1; J <= MAX; J++) {
            setCO(-J, I, CO(J, I));
            setSI(-J, I, -SI(J, I));
        }
    }

    function Term(p, q, r, s) {
        const indices = [0, p, q, r, s];
        let rx = 1, ry = 0;
        for (let k = 1; k <= 4; k++) {
            if (indices[k] !== 0) {
                addThe(rx, ry, CO(indices[k], k), SI(indices[k], k), (c, s) => { rx = c; ry = s; });
            }
        }
        return { x: rx, y: ry };
    }

    function addSol(coeffl, coeffs, coeffg, coeffp, p, q, r, s) {
        const result = Term(p, q, r, s);
        DLAM  += coeffl * result.y;
        DS    += coeffs * result.y;
        GAM1C += coeffg * result.x;
        SINPI += coeffp * result.x;
    }

    // Major lunar terms
    addSol(13.9020, 14.0600, -0.0010, 0.2607, 0, 0, 0, 4);
    addSol(0.4030, -4.0100, 0.3940, 0.0023, 0, 0, 0, 3);
    addSol(2369.9120, 2373.3600, 0.6010, 28.2333, 0, 0, 0, 2);
    addSol(-125.1540, -112.7900, -0.7250, -0.9781, 0, 0, 0, 1);
    addSol(1.9790, 6.9800, -0.4450, 0.0433, 1, 0, 0, 4);
    addSol(191.9530, 192.7200, 0.0290, 3.0861, 1, 0, 0, 2);
    addSol(-8.4660, -13.5100, 0.4550, -0.1093, 1, 0, 0, 1);
    addSol(22639.5000, 22609.0700, 0.0790, 186.5398, 1, 0, 0, 0);
    addSol(18.6090, 3.5900, -0.0940, 0.0118, 1, 0, 0, -1);
    addSol(-4586.4650, -4578.1300, -0.0770, 34.3117, 1, 0, 0, -2);
    addSol(3.2150, 5.4400, 0.1920, -0.0386, 1, 0, 0, -3);
    addSol(-38.4280, -38.6400, 0.0010, 0.6008, 1, 0, 0, -4);
    addSol(-0.3930, -1.4300, -0.0920, 0.0086, 1, 0, 0, -6);
    addSol(-0.2890, -1.5900, 0.1230, -0.0053, 0, 1, 0, 4);
    addSol(-24.4200, -25.1000, 0.0400, -0.3000, 0, 1, 0, 2);
    addSol(18.0230, 17.9300, 0.0070, 0.1494, 0, 1, 0, 1);
    addSol(-668.1460, -126.9800, -1.3020, -0.3997, 0, 1, 0, 0);
    addSol(0.5600, 0.3200, -0.0010, -0.0037, 0, 1, 0, -1);
    addSol(-165.1450, -165.0600, 0.0540, 1.9178, 0, 1, 0, -2);
    addSol(-1.8770, -6.4600, -0.4160, 0.0339, 0, 1, 0, -4);
    addSol(0.2130, 1.0200, -0.0740, 0.0054, 2, 0, 0, 4);
    addSol(14.3870, 14.7800, -0.0170, 0.2833, 2, 0, 0, 2);
    addSol(-0.5860, -1.2000, 0.0540, -0.0100, 2, 0, 0, 1);
    addSol(769.0160, 767.9600, 0.1070, 10.1657, 2, 0, 0, 0);
    addSol(1.7500, 2.0100, -0.0180, 0.0155, 2, 0, 0, -1);
    addSol(-211.6560, -152.5300, 5.6790, -0.3039, 2, 0, 0, -2);
    addSol(1.2250, 0.9100, -0.0300, -0.0088, 2, 0, 0, -3);
    addSol(-30.7730, -34.0700, -0.3080, 0.3722, 2, 0, 0, -4);
    addSol(-0.5700, -1.4000, -0.0740, 0.0109, 2, 0, 0, -6);
    addSol(-2.9210, -11.7500, 0.7870, -0.0484, 1, 1, 0, 2);
    addSol(1.2670, 1.5200, -0.0220, 0.0164, 1, 1, 0, 1);
    addSol(-109.6730, -115.1800, 0.4610, -0.9490, 1, 1, 0, 0);
    addSol(-205.9620, -182.3600, 2.0560, 1.4437, 1, 1, 0, -2);
    addSol(0.2330, 0.3600, 0.0120, -0.0025, 1, 1, 0, -3);
    addSol(-4.3910, -9.6600, -0.4710, 0.0673, 1, 1, 0, -4);
    addSol(0.2830, 1.5300, -0.1110, 0.0060, 1, -1, 0, 4);
    addSol(14.5770, 31.7000, -1.5400, 0.2302, 1, -1, 0, 2);
    addSol(147.6870, 138.7600, 0.6790, 1.1528, 1, -1, 0, 0);
    addSol(-1.0890, 0.5500, 0.0210, 0.0000, 1, -1, 0, -1);
    addSol(28.4750, 23.5900, -0.4430, -0.2257, 1, -1, 0, -2);
    addSol(-0.2760, -0.3800, -0.0060, -0.0036, 1, -1, 0, -3);
    addSol(0.6360, 2.2700, 0.1460, -0.0102, 1, -1, 0, -4);
    addSol(-0.1890, -1.6800, 0.1310, -0.0028, 0, 2, 0, 2);
    addSol(-7.4860, -0.6600, -0.0370, -0.0086, 0, 2, 0, 0);
    addSol(-8.0960, -16.3500, -0.7400, 0.0918, 0, 2, 0, -2);
    addSol(-5.7410, -0.0400, 0.0000, -0.0009, 0, 0, 2, 2);
    addSol(0.2550, 0.0000, 0.0000, 0.0000, 0, 0, 2, 1);
    addSol(-411.6080, -0.2000, 0.0000, -0.0124, 0, 0, 2, 0);
    addSol(0.5840, 0.8400, 0.0000, 0.0071, 0, 0, 2, -1);
    addSol(-55.1730, -52.1400, 0.0000, -0.1052, 0, 0, 2, -2);
    addSol(0.2540, 0.2500, 0.0000, -0.0017, 0, 0, 2, -3);
    addSol(0.0250, -1.6700, 0.0000, 0.0031, 0, 0, 2, -4);
    addSol(1.0600, 2.9600, -0.1660, 0.0243, 3, 0, 0, 2);
    addSol(36.1240, 50.6400, -1.3000, 0.6215, 3, 0, 0, 0);
    addSol(-13.1930, -16.4000, 0.2580, -0.1187, 3, 0, 0, -2);
    addSol(-1.1870, -0.7400, 0.0420, 0.0074, 3, 0, 0, -4);
    addSol(-0.2930, -0.3100, -0.0020, 0.0046, 3, 0, 0, -6);
    addSol(-0.2900, -1.4500, 0.1160, -0.0051, 2, 1, 0, 2);
    addSol(-7.6490, -10.5600, 0.2590, -0.1038, 2, 1, 0, 0);
    addSol(-8.6270, -7.5900, 0.0780, -0.0192, 2, 1, 0, -2);
    addSol(-2.7400, -2.5400, 0.0220, 0.0324, 2, 1, 0, -4);
    addSol(1.1810, 3.3200, -0.2120, 0.0213, 2, -1, 0, 2);
    addSol(9.7030, 11.6700, -0.1510, 0.1268, 2, -1, 0, 0);
    addSol(-0.3520, -0.3700, 0.0010, -0.0028, 2, -1, 0, -1);
    addSol(-2.4940, -1.1700, -0.0030, -0.0017, 2, -1, 0, -2);
    addSol(0.3600, 0.2000, -0.0120, -0.0043, 2, -1, 0, -4);
    addSol(-1.1670, -1.2500, 0.0080, -0.0106, 1, 2, 0, 0);
    addSol(-7.4120, -6.1200, 0.1170, 0.0484, 1, 2, 0, -2);
    addSol(-0.3110, -0.6500, -0.0320, 0.0044, 1, 2, 0, -4);
    addSol(0.7570, 1.8200, -0.1050, 0.0112, 1, -2, 0, 2);
    addSol(2.5800, 2.3200, 0.0270, 0.0196, 1, -2, 0, 0);
    addSol(2.5330, 2.4000, -0.0140, -0.0212, 1, -2, 0, -2);
    addSol(-0.3440, -0.5700, -0.0250, 0.0036, 0, 3, 0, -2);
    addSol(-0.9920, -0.0200, 0.0000, 0.0000, 1, 0, 2, 2);
    addSol(-45.0990, -0.0200, 0.0000, -0.0010, 1, 0, 2, 0);
    addSol(-0.1790, -9.5200, 0.0000, -0.0833, 1, 0, 2, -2);
    addSol(-0.3010, -0.3300, 0.0000, 0.0014, 1, 0, 2, -4);
    addSol(-6.3820, -3.3700, 0.0000, -0.0481, 1, 0, -2, 2);
    addSol(39.5280, 85.1300, 0.0000, -0.7136, 1, 0, -2, 0);
    addSol(9.3660, 0.7100, 0.0000, -0.0112, 1, 0, -2, -2);
    addSol(0.2020, 0.0200, 0.0000, 0.0000, 1, 0, -2, -4);
    addSol(0.4150, 0.1000, 0.0000, 0.0013, 0, 1, 2, 0);
    addSol(-2.1520, -2.2600, 0.0000, -0.0066, 0, 1, 2, -2);
    addSol(-1.4400, -1.3000, 0.0000, 0.0014, 0, 1, -2, 2);
    addSol(0.3840, -0.0400, 0.0000, 0.0000, 0, 1, -2, -2);
    addSol(1.9380, 3.6000, -0.1450, 0.0401, 4, 0, 0, 0);
    addSol(-0.9520, -1.5800, 0.0520, -0.0130, 4, 0, 0, -2);
    addSol(-0.5510, -0.9400, 0.0320, -0.0097, 3, 1, 0, 0);
    addSol(-0.4820, -0.5700, 0.0050, -0.0045, 3, 1, 0, -2);
    addSol(0.6810, 0.9600, -0.0260, 0.0115, 3, -1, 0, 0);
    addSol(-0.2970, -0.2700, 0.0020, -0.0009, 2, 2, 0, -2);
    addSol(0.2540, 0.2100, -0.0030, 0.0000, 2, -2, 0, -2);
    addSol(-0.2500, -0.2200, 0.0040, 0.0014, 1, 3, 0, -2);
    addSol(-3.9960, 0.0000, 0.0000, 0.0004, 2, 0, 2, 0);
    addSol(0.5570, -0.7500, 0.0000, -0.0090, 2, 0, 2, -2);
    addSol(-0.4590, -0.3800, 0.0000, -0.0053, 2, 0, -2, 2);
    addSol(-1.2980, 0.7400, 0.0000, 0.0004, 2, 0, -2, 0);
    addSol(0.5380, 1.1400, 0.0000, -0.0141, 2, 0, -2, -2);
    addSol(0.2630, 0.0200, 0.0000, 0.0000, 1, 1, 2, 0);
    addSol(0.4260, 0.0700, 0.0000, -0.0006, 1, 1, -2, -2);
    addSol(-0.3040, 0.0300, 0.0000, 0.0003, 1, -1, 2, 0);
    addSol(-0.3720, -0.1900, 0.0000, -0.0027, 1, -1, -2, 2);
    addSol(0.4180, 0.0000, 0.0000, 0.0000, 0, 0, 4, 0);
    addSol(-0.3300, -0.0400, 0.0000, 0.0000, 3, 0, 2, 0);

    // Node terms
    function addn(coeffn, p, q, r, s) {
        return coeffn * Term(p, q, r, s).y;
    }

    N = 0;
    N += addn(-526.069, 0, 0, 1, -2);
    N += addn(-3.352, 0, 0, 1, -4);
    N += addn(+44.297, 1, 0, 1, -2);
    N += addn(-6.000, 1, 0, 1, -4);
    N += addn(+20.599, -1, 0, 1, 0);
    N += addn(-30.598, -1, 0, 1, -2);
    N += addn(-24.649, -2, 0, 1, 0);
    N += addn(-2.000, -2, 0, 1, -2);
    N += addn(-22.571, 0, 1, 1, -2);
    N += addn(+10.985, 0, -1, 1, -2);

    // Additional longitude terms
    DLAM += (
        +0.82 * Sine(0.7736 - 62.5512 * T) + 0.31 * Sine(0.0466 - 125.1025 * T)
        + 0.35 * Sine(0.5785 - 25.1042 * T) + 0.66 * Sine(0.4591 + 1335.8075 * T)
        + 0.64 * Sine(0.3130 - 91.5680 * T) + 1.14 * Sine(0.1480 + 1331.2898 * T)
        + 0.21 * Sine(0.5918 + 1056.5859 * T) + 0.44 * Sine(0.5784 + 1322.8595 * T)
        + 0.24 * Sine(0.2275 - 5.7374 * T) + 0.28 * Sine(0.2965 + 2.6929 * T)
        + 0.33 * Sine(0.3132 + 6.3368 * T)
    );

    const S = F + DS / ARC;
    const lat_seconds = (1.000002708 + 139.978 * DGAM) * (18518.511 + 1.189 + GAM1C) * Math.sin(S)
                      - 6.24 * Math.sin(3 * S) + N;

    return {
        geo_eclip_lon: PI2 * frac((L0 + DLAM / ARC) / PI2),
        geo_eclip_lat: (Math.PI / (180 * 3600)) * lat_seconds,
        distance_au: (ARC * EARTH_EQUATORIAL_RADIUS_AU) / (0.999953253 * SINPI)
    };
}

function moonLongitude(jd) {
    const time = jdToTime(jd);
    const moon = calcMoon(time);
    const distCosLat = moon.distance_au * Math.cos(moon.geo_eclip_lat);
    const ecm = [
        distCosLat * Math.cos(moon.geo_eclip_lon),
        distCosLat * Math.sin(moon.geo_eclip_lon),
        moon.distance_au * Math.sin(moon.geo_eclip_lat)
    ];
    const et = e_tilt(time);
    const eqm = oblEcl2Equ(et.mobl, ecm);
    const eqd = nutationVec(eqm, time, true);
    const cosTobl = Math.cos(et.tobl * DEG2RAD);
    const sinTobl = Math.sin(et.tobl * DEG2RAD);
    return rotateEquatorialToEcliptic(eqd[0], eqd[1], eqd[2], cosTobl, sinTobl).elon;
}

// ===========================================================
//  Ayanamsa (Lahiri)
// ===========================================================

function ayanamsa(jd) {
    const time = jdToTime(jd);
    const t = time.tt / 36525;
    // Precession in longitude (arcseconds) from J2000
    const psia = (((((-0.0000000951 * t
        + 0.000132851) * t
        - 0.00114045) * t
        - 1.0790069) * t
        + 5038.481507) * t);
    // Lahiri ayanamsa: offset at J2000.0 = 23.856083°
    return psia / 3600 + 23.856083;
}

// ===========================================================
//  Observer & Terrestrial Position
// ===========================================================

function terra(observer, st) {
    const phi = observer.latitude * DEG2RAD;
    const sinphi = Math.sin(phi);
    const cosphi = Math.cos(phi);
    const c = 1 / Math.hypot(cosphi, EARTH_FLATTENING * sinphi);
    const s = EARTH_FLATTENING_SQUARED * c;
    const htKm = observer.height / 1000;
    const ach = EARTH_EQUATORIAL_RADIUS_KM * c + htKm;
    const ash = EARTH_EQUATORIAL_RADIUS_KM * s + htKm;
    const stlocl = (15 * st + observer.longitude) * DEG2RAD;
    const sinst = Math.sin(stlocl);
    const cosst = Math.cos(stlocl);
    return [
        ach * cosphi * cosst / KM_PER_AU,
        ach * cosphi * sinst / KM_PER_AU,
        ash * sinphi / KM_PER_AU
    ];
}

function era(time) {
    const thet1 = 0.7790572732640 + 0.00273781191135448 * time.ut;
    const thet3 = time.ut % 1;
    let theta = 360 * ((thet1 + thet3) % 1);
    if (theta < 0) theta += 360;
    return theta;
}

let _sidereal_time_cache = null;

function siderealTime(time) {
    if (!_sidereal_time_cache || _sidereal_time_cache.tt !== time.tt) {
        const t = time.tt / 36525;
        const eqeq = 15 * e_tilt(time).ee;
        const theta = era(time);
        const st = (eqeq + 0.014506 +
            (((( -0.0000000368 * t
                - 0.000029956) * t
                - 0.00000044) * t
                + 1.3915817) * t
                + 4612.156534) * t);
        let gst = ((st / 3600 + theta) % 360) / 15;
        if (gst < 0) gst += 24;
        _sidereal_time_cache = { tt: time.tt, st: gst };
    }
    return _sidereal_time_cache.st;
}

function geoPos(time, observer) {
    const gast = siderealTime(time);
    const pos = terra(observer, gast);
    return gyration(pos, time, false);
}

// ===========================================================
//  spin – rotate a vector around the z-axis
// ===========================================================

function spin(angle, pos) {
    const angr = angle * DEG2RAD;
    const c = Math.cos(angr), s = Math.sin(angr);
    return [c * pos[0] + s * pos[1], c * pos[1] - s * pos[0], pos[2]];
}

// ===========================================================
//  vector2radec
// ===========================================================

function vector2radec(pos) {
    const xyproj = pos[0] * pos[0] + pos[1] * pos[1];
    const dist = Math.sqrt(xyproj + pos[2] * pos[2]);
    if (xyproj === 0) {
        return { ra: 0, dec: pos[2] < 0 ? -90 : 90, dist };
    }
    let ra = RAD2HOUR * Math.atan2(pos[1], pos[0]);
    if (ra < 0) ra += 24;
    const dec = RAD2DEG * Math.atan2(pos[2], Math.sqrt(xyproj));
    return { ra, dec, dist };
}

// ===========================================================
//  Horizon – topocentric horizontal coordinates
// ===========================================================

function horizon(time, observer, ra, dec) {
    const sinlat = Math.sin(observer.latitude * DEG2RAD);
    const coslat = Math.cos(observer.latitude * DEG2RAD);
    const sinlon = Math.sin(observer.longitude * DEG2RAD);
    const coslon = Math.cos(observer.longitude * DEG2RAD);
    const sindc = Math.sin(dec * DEG2RAD);
    const cosdc = Math.cos(dec * DEG2RAD);
    const sinra = Math.sin(ra * HOUR2RAD);
    const cosra = Math.cos(ra * HOUR2RAD);

    const uze = [coslat * coslon, coslat * sinlon, sinlat];
    const une = [-sinlat * coslon, -sinlat * sinlon, coslat];
    const uwe = [sinlon, -coslon, 0];

    const spinAngle = -15 * siderealTime(time);
    const uz = spin(spinAngle, uze);
    const un = spin(spinAngle, une);
    const uw = spin(spinAngle, uwe);

    const p = [cosdc * cosra, cosdc * sinra, sindc];

    const pz = p[0] * uz[0] + p[1] * uz[1] + p[2] * uz[2];
    const pn = p[0] * un[0] + p[1] * un[1] + p[2] * un[2];
    const pw = p[0] * uw[0] + p[1] * uw[1] + p[2] * uw[2];

    const proj = Math.hypot(pn, pw);
    let az = 0;
    if (proj > 0) {
        az = -RAD2DEG * Math.atan2(pw, pn);
        if (az < 0) az += 360;
    }
    const zd = RAD2DEG * Math.atan2(proj, pz);
    return { azimuth: az, altitude: 90 - zd };
}

// ===========================================================
//  Equator – topocentric equatorial coordinates
// ===========================================================

function equator(body, time, observer, aberration) {
    const gcObserver = geoPos(time, observer);
    const gc = geoVector(body, time, aberration);
    const j2000 = [
        gc[0] - gcObserver[0],
        gc[1] - gcObserver[1],
        gc[2] - gcObserver[2]
    ];
    const datevect = gyration(j2000, time, true);
    return vector2radec(datevect);
}

// ===========================================================
//  GeoVector – geocentric position of a body
// ===========================================================

function geoVector(body, time, aberration) {
    if (body === BODY_SUN) {
        return backdatePosition(time, 'Earth', BODY_SUN, aberration);
    }
    throw `geoVector: unsupported body "${body}"`;
}

function helioVector(body, time) {
    if (body === BODY_SUN) return [0, 0, 0];
    if (body === 'Earth') return calcVsop(time);
    throw `helioVector: unsupported body "${body}"`;
}

function backdatePosition(time, observerBody, targetBody, aberration) {
    function position(t) {
        let obsPos;
        if (aberration) {
            obsPos = helioVector(observerBody, t);
        } else {
            obsPos = helioVector(observerBody, time);
        }
        const tgtPos = helioVector(targetBody, t);
        return [tgtPos[0] - obsPos[0], tgtPos[1] - obsPos[1], tgtPos[2] - obsPos[2]];
    }

    let ltime = time;
    for (let iter = 0; iter < 10; iter++) {
        const pos = position(ltime);
        const lt = Math.hypot(pos[0], pos[1], pos[2]) / C_AUDAY;
        if (lt > 1.0) throw 'Object too distant for light-travel solver.';
        const ltime2 = addDays(time, -lt);
        if (Math.abs(ltime2.tt - ltime.tt) < 1.0e-9) {
            ltime = time;
            return pos;
        }
        ltime = ltime2;
    }
    ltime = time;
    return position(ltime);
}

// ===========================================================
//  Atmosphere model
// ===========================================================

function atmosphere(elevationMeters) {
    const P0 = 101325.0;
    const T0 = 288.15;
    const T1 = 216.65;
    let temperature, pressure;
    if (elevationMeters <= 11000.0) {
        temperature = T0 - 0.0065 * elevationMeters;
        pressure = P0 * Math.pow(T0 / temperature, -5.25577);
    } else if (elevationMeters <= 20000.0) {
        temperature = T1;
        pressure = 22632.0 * Math.exp(-0.00015768832 * (elevationMeters - 11000.0));
    } else {
        temperature = T1 + 0.001 * (elevationMeters - 20000.0);
        pressure = 5474.87 * Math.pow(T1 / temperature, 34.16319);
    }
    return (pressure / temperature) / (P0 / T0);
}

// ===========================================================
//  Horizon dip angle
// ===========================================================

function horizonDipAngle(observer, metersAboveGround) {
    const phi = observer.latitude * DEG2RAD;
    const sinphi = Math.sin(phi);
    const cosphi = Math.cos(phi);
    const c = 1.0 / Math.hypot(cosphi, sinphi * EARTH_FLATTENING);
    const s = c * EARTH_FLATTENING_SQUARED;
    const htKm = (observer.height - metersAboveGround) / 1000.0;
    const ach = EARTH_EQUATORIAL_RADIUS_KM * c + htKm;
    const ash = EARTH_EQUATORIAL_RADIUS_KM * s + htKm;
    const radiusM = 1000.0 * Math.hypot(ach * cosphi, ash * sinphi);
    const k = 0.175 * Math.pow(1.0 - (6.5e-3 / 283.15) * (observer.height - (2.0 / 3.0) * metersAboveGround), 3.256);
    return RAD2DEG * -(Math.sqrt(2 * (1 - k) * metersAboveGround / radiusM) / (1 - k));
}

// ===========================================================
//  Max altitude slope
// ===========================================================

function maxAltitudeSlope(body, latitude) {
    let derivRa, derivDec;
    if (body === BODY_MOON) {
        derivRa = 4.5; derivDec = 8.2;
    } else if (body === BODY_SUN) {
        derivRa = 0.8; derivDec = 0.5;
    } else {
        throw `maxAltitudeSlope: unsupported body "${body}"`;
    }
    const latRad = DEG2RAD * latitude;
    return Math.abs(((360.0 / SOLAR_DAYS_PER_SIDEREAL_DAY) - derivRa) * Math.cos(latRad))
         + Math.abs(derivDec * Math.sin(latRad));
}

// ===========================================================
//  Search for zero-crossing (quadratic interpolation)
// ===========================================================

function quadInterp(tm, dt, fa, fm, fb) {
    const Q = (fb + fa) / 2 - fm;
    const R = (fb - fa) / 2;
    const S = fm;
    let x;

    if (Q === 0) {
        if (R === 0) return null;
        x = -S / R;
        if (x < -1 || x > +1) return null;
    } else {
        const u = R * R - 4 * Q * S;
        if (u <= 0) return null;
        const ru = Math.sqrt(u);
        const x1 = (-R + ru) / (2 * Q);
        const x2 = (-R - ru) / (2 * Q);
        if (-1 <= x1 && x1 <= +1) {
            if (-1 <= x2 && x2 <= +1) return null;
            x = x1;
        } else if (-1 <= x2 && x2 <= +1) {
            x = x2;
        } else {
            return null;
        }
    }
    const t = tm + x * dt;
    const df_dt = (2 * Q * x + R) / dt;
    return { t, df_dt };
}

function search(f, t1, t2, options) {
    const dtToleranceSeconds = (options && options.dt_tolerance_seconds) || 1;
    const dtDays = Math.abs(dtToleranceSeconds / SECONDS_PER_DAY);
    let f1 = (options && options.init_f1 != null) ? options.init_f1 : f(t1);
    let f2 = (options && options.init_f2 != null) ? options.init_f2 : f(t2);
    let fmid = NaN;
    let iter = 0;
    const iterLimit = (options && options.iter_limit) || 20;
    let calcFmid = true;

    while (true) {
        if (++iter > iterLimit) throw 'Excessive iteration in search()';
        const tmid = { ut: (t1.ut + t2.ut) / 2, tt: 0 };
        tmid.tt = terrestrialTime(tmid.ut);
        const dt = tmid.ut - t1.ut;
        if (Math.abs(dt) < dtDays) return tmid;

        if (calcFmid) fmid = f(tmid);
        else calcFmid = true;

        const q = quadInterp(tmid.ut, t2.ut - tmid.ut, f1, fmid, f2);
        if (q) {
            const tq = { ut: q.t, tt: terrestrialTime(q.t) };
            const fq = f(tq);
            if (q.df_dt !== 0 && Math.abs(fq / q.df_dt) < dtDays) return tq;
            if (q.df_dt !== 0) {
                const dtGuess = 1.2 * Math.abs(fq / q.df_dt);
                if (dtGuess < dt / 10) {
                    const tleft = addDays(tq, -dtGuess);
                    const tright = addDays(tq, +dtGuess);
                    if ((tleft.ut - t1.ut) * (tleft.ut - t2.ut) < 0 &&
                        (tright.ut - t1.ut) * (tright.ut - t2.ut) < 0) {
                        const fleft = f(tleft);
                        const fright = f(tright);
                        if (fleft < 0 && fright >= 0) {
                            f1 = fleft; f2 = fright;
                            t1 = tleft; t2 = tright;
                            fmid = fq; calcFmid = false;
                            continue;
                        }
                    }
                }
            }
        }
        if (f1 < 0 && fmid >= 0) { t2 = tmid; f2 = fmid; continue; }
        if (fmid < 0 && f2 >= 0) { t1 = tmid; f1 = fmid; continue; }
        return null;
    }
}

// ===========================================================
//  Find ascending zero crossing (recursive bisection)
// ===========================================================

function findAscent(depth, altdiff, maxDeriv, t1, t2, a1, a2) {
    if (a1 < 0 && a2 >= 0) return { tx: t1, ty: t2, ax: a1, ay: a2 };
    if (a1 >= 0 && a2 < 0) return null;
    if (depth > 17) throw 'Excessive recursion in rise/set ascent search.';
    const dt = t2.ut - t1.ut;
    if (dt * SECONDS_PER_DAY < 1.0) return null;
    const da = Math.min(Math.abs(a1), Math.abs(a2));
    if (da > maxDeriv * (dt / 2)) return null;
    const tmid = { ut: (t1.ut + t2.ut) / 2, tt: terrestrialTime((t1.ut + t2.ut) / 2) };
    const amid = altdiff(tmid);
    return findAscent(1 + depth, altdiff, maxDeriv, t1, tmid, a1, amid)
        || findAscent(1 + depth, altdiff, maxDeriv, tmid, t2, amid, a2);
}

// ===========================================================
//  Internal altitude search
// ===========================================================

function internalSearchAltitude(body, observer, direction, dateStart, limitDays, bodyRadiusAu, targetAltitude) {
    const RISE_SET_DT = 0.42;
    const maxDeriv = maxAltitudeSlope(body, observer.latitude);

    function altdiff(time) {
        const eq = equator(body, time, observer, true);
        const hor = horizon(time, observer, eq.ra, eq.dec);
        const altitude = hor.altitude + RAD2DEG * Math.asin(bodyRadiusAu / eq.dist);
        return direction * (altitude - targetAltitude);
    }

    const startTime = dateToTime(dateStart);
    let t1 = startTime, t2 = startTime;
    let a1 = altdiff(t1), a2 = a1;

    for (;;) {
        if (limitDays < 0) {
            t1 = addDays(t2, -RISE_SET_DT);
            a1 = altdiff(t1);
        } else {
            t2 = addDays(t1, +RISE_SET_DT);
            a2 = altdiff(t2);
        }
        const ascent = findAscent(0, altdiff, maxDeriv, t1, t2, a1, a2);
        if (ascent) {
            const time = search(altdiff, ascent.tx, ascent.ty, {
                dt_tolerance_seconds: 0.1,
                init_f1: ascent.ax,
                init_f2: ascent.ay
            });
            if (time) {
                if (limitDays < 0 && time.ut < startTime.ut + limitDays) return null;
                if (limitDays > 0 && time.ut > startTime.ut + limitDays) return null;
                return time;
            }
            throw 'Rise/set search failed after finding ascent';
        }
        if (limitDays < 0) {
            if (t1.ut < startTime.ut + limitDays) return null;
            t2 = t1; a2 = a1;
        } else {
            if (t2.ut > startTime.ut + limitDays) return null;
            t1 = t2; a1 = a2;
        }
    }
}

// ===========================================================
//  Search rise/set
// ===========================================================

function searchRiseSet(body, observer, direction, dateStart, limitDays) {
    const bodyRadiusAu = body === BODY_SUN ? SUN_RADIUS_AU : 0;
    const atmos = atmosphere(observer.height);
    const dip = horizonDipAngle(observer, 0);
    const altitude = dip - (REFRACTION_NEAR_HORIZON * atmos);
    return internalSearchAltitude(body, observer, direction, dateStart, limitDays, bodyRadiusAu, altitude);
}

// ===========================================================
//  Public API
// ===========================================================

/**
 * Convert a JavaScript Date to a Julian Day number.
 * @param {Date} date
 * @returns {number} Julian Day (Terrestrial Time)
 */
export function julianDay(date) {
    const time = dateToTime(date);
    return time.ut + 2451545.0;
}

/**
 * Geocentric ecliptic longitude of the Sun (degrees, 0..360).
 * @param {number} jd  Julian Day (TT)
 * @returns {number}
 */
export { sunLongitude };

/**
 * Geocentric ecliptic longitude of the Moon (degrees, 0..360).
 * @param {number} jd  Julian Day (TT)
 * @returns {number}
 */
export { moonLongitude };

/**
 * Lahiri ayanamsa (degrees).
 * @param {number} jd  Julian Day (TT)
 * @returns {number}
 */
export { ayanamsa };

/**
 * Calculate sunrise time for a given date and location.
 * @param {Date}   date      JavaScript Date (any time on the desired day)
 * @param {number} latitude  Observer latitude in degrees (north positive)
 * @param {number} longitude Observer longitude in degrees (east positive)
 * @returns {Date} JavaScript Date of sunrise (UTC)
 */
export function sunrise(date, latitude, longitude) {
    const observer = { latitude, longitude, height: 0 };
    const result = searchRiseSet(BODY_SUN, observer, +1, date, 1);
    if (!result) throw 'No sunrise found';
    return new Date(J2000.getTime() + result.ut * MILLIS_PER_DAY);
}

/**
 * Calculate sunset time for a given date and location.
 * @param {Date}   date      JavaScript Date (any time on the desired day)
 * @param {number} latitude  Observer latitude in degrees (north positive)
 * @param {number} longitude Observer longitude in degrees (east positive)
 * @returns {Date} JavaScript Date of sunset (UTC)
 */
export function sunset(date, latitude, longitude) {
    const observer = { latitude, longitude, height: 0 };
    const result = searchRiseSet(BODY_SUN, observer, -1, date, 1);
    if (!result) throw 'No sunset found';
    return new Date(J2000.getTime() + result.ut * MILLIS_PER_DAY);
}
