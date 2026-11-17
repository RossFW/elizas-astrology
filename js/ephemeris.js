// ephemeris.js — Astronomical calculations ported from Ephemeris.swift
// Meeus algorithms, Keplerian elements (JPL Standish 1992), Placidus houses
// All constants and math identical to the validated Swift implementation.

// MARK: - Math Helpers

const deg2rad = Math.PI / 180.0;
const rad2deg = 180.0 / Math.PI;

function normalizeAngle(angle) {
    let a = angle % 360.0;
    if (a < 0) a += 360.0;
    return a;
}

function sinDeg(deg) { return Math.sin(deg * deg2rad); }
function cosDeg(deg) { return Math.cos(deg * deg2rad); }
function tanDeg(deg) { return Math.tan(deg * deg2rad); }
function asinDeg(x) { return Math.asin(x) * rad2deg; }
function atan2Deg(y, x) { return Math.atan2(y, x) * rad2deg; }

// MARK: - Julian Date

const JulianDate = {
    fromDate(year, month, day) {
        let y = year;
        let m = month;
        if (m <= 2) {
            y -= 1;
            m += 12;
        }
        const A = Math.floor(y / 100.0);
        const B = 2 - A + Math.floor(A / 4.0);
        return Math.floor(365.25 * (y + 4716)) + Math.floor(30.6001 * (m + 1)) + day + B - 1524.5;
    },

    fromJSDate(date) {
        const year = date.getUTCFullYear();
        const month = date.getUTCMonth() + 1;
        const day = date.getUTCDate() +
            date.getUTCHours() / 24.0 +
            date.getUTCMinutes() / 1440.0 +
            date.getUTCSeconds() / 86400.0;
        return JulianDate.fromDate(year, month, day);
    },

    centuriesFromJ2000(jd) {
        return (jd - 2451545.0) / 36525.0;
    }
};

// MARK: - Obliquity of Ecliptic

function meanObliquity(T) {
    return 23.439291 - 0.0130042 * T - 1.64e-7 * T * T + 5.04e-7 * T * T * T;
}

// MARK: - Nutation

function nutation(T) {
    const omega = 125.04452 - 1934.136261 * T;
    const L0 = 280.4665 + 36000.7698 * T;
    const Lp = 218.3165 + 481267.8813 * T;
    const dPsi = -17.2 / 3600.0 * sinDeg(omega) - 1.32 / 3600.0 * sinDeg(2 * L0) -
                 0.23 / 3600.0 * sinDeg(2 * Lp) + 0.21 / 3600.0 * sinDeg(2 * omega);
    const dEps = 9.2 / 3600.0 * cosDeg(omega) + 0.57 / 3600.0 * cosDeg(2 * L0) +
                 0.10 / 3600.0 * cosDeg(2 * Lp) - 0.09 / 3600.0 * cosDeg(2 * omega);
    return { longitude: dPsi, obliquity: dEps };
}

// MARK: - Sidereal Time

function greenwichMeanSiderealTime(jd) {
    const T = JulianDate.centuriesFromJ2000(jd);
    const gmst = 280.46061837 + 360.98564736629 * (jd - 2451545.0) +
                 0.000387933 * T * T - T * T * T / 38710000.0;
    return normalizeAngle(gmst);
}

function localSiderealTime(jd, longitude) {
    return normalizeAngle(greenwichMeanSiderealTime(jd) + longitude);
}

// MARK: - Sun Position (Meeus Ch. 25)

const SunCalculator = {
    position(jd) {
        const T = JulianDate.centuriesFromJ2000(jd);
        const L0 = normalizeAngle(280.46646 + 36000.76983 * T + 0.0003032 * T * T);
        const M = normalizeAngle(357.52911 + 35999.05029 * T - 0.0001537 * T * T);
        const C = (1.914602 - 0.004817 * T - 0.000014 * T * T) * sinDeg(M) +
                  (0.019993 - 0.000101 * T) * sinDeg(2 * M) +
                  0.000289 * sinDeg(3 * M);
        const sunLon = L0 + C;
        const omega = 125.04 - 1934.136 * T;
        const apparent = sunLon - 0.00569 - 0.00478 * sinDeg(omega);
        return { longitude: normalizeAngle(apparent), meanAnomaly: M };
    }
};

// MARK: - Moon Position (Meeus Ch. 47)

const MoonCalculator = {
    longitude(jd) {
        const T = JulianDate.centuriesFromJ2000(jd);
        const Lp = normalizeAngle(218.3164477 + 481267.88123421 * T -
                                  0.0015786 * T * T + T * T * T / 538841.0);
        const D = normalizeAngle(297.8501921 + 445267.1114034 * T -
                                 0.0018819 * T * T + T * T * T / 545868.0);
        const M = normalizeAngle(357.5291092 + 35999.0502909 * T -
                                 0.0001536 * T * T);
        const Mp = normalizeAngle(134.9633964 + 477198.8675055 * T +
                                  0.0087414 * T * T + T * T * T / 69699.0);
        const F = normalizeAngle(93.2720950 + 483202.0175233 * T -
                                 0.0036539 * T * T);

        const E = 1.0 - 0.002516 * T - 0.0000074 * T * T;
        const E2 = E * E;

        // Longitude terms: [D, M, Mp, F, coefficient]
        // M multiplier determines E correction: |M|=1 -> *E, |M|=2 -> *E^2
        const terms = [
            [0, 0, 1, 0, 6288774],
            [2, 0, -1, 0, 1274027],
            [2, 0, 0, 0, 658314],
            [0, 0, 2, 0, 213618],
            [0, 1, 0, 0, -185116],
            [0, 0, 0, 2, -114332],
            [2, 0, -2, 0, 58793],
            [2, -1, -1, 0, 57066],
            [2, 0, 1, 0, 53322],
            [2, -1, 0, 0, 45758],
            [0, 1, -1, 0, -40923],
            [1, 0, 0, 0, -34720],
            [0, 1, 1, 0, -30383],
            [2, 0, 0, -2, 15327],
            [0, 0, 1, 2, -12528],
            [0, 0, 1, -2, 10980],
            [4, 0, -1, 0, 10675],
            [0, 0, 3, 0, 10034],
            [4, 0, -2, 0, 8548],
            [2, 1, -1, 0, -7888],
            [2, 1, 0, 0, -6766],
            [1, 0, -1, 0, -5163],
            [1, 1, 0, 0, 4987],
            [2, -1, 1, 0, 4036],
            [2, 0, 2, 0, 3994],
            [4, 0, 0, 0, 3861],
            [2, 0, -3, 0, 3665],
            [0, 1, -2, 0, -2689],
            [2, 0, -1, 2, -2602],
            [2, -1, -2, 0, 2390],
        ];

        let sumL = 0;
        for (const term of terms) {
            const arg = term[0] * D + term[1] * M + term[2] * Mp + term[3] * F;
            let c = term[4];
            const absM = Math.abs(term[1]);
            if (absM === 1) c *= E;
            else if (absM === 2) c *= E2;
            sumL += c * sinDeg(arg);
        }

        // A1, A2 corrections
        const A1 = normalizeAngle(119.75 + 131.849 * T);
        const A2 = normalizeAngle(53.09 + 479264.290 * T);
        sumL += 3958 * sinDeg(A1) + 1962 * sinDeg(Lp - F) + 318 * sinDeg(A2);

        return normalizeAngle(Lp + sumL / 1000000.0);
    }
};

// MARK: - Planet Positions (Keplerian Elements + Kepler Equation)

// Orbital element rates: L0, dL, a0, da, e0, de, I0, dI, omega0, dOmega, pi0, dPi
// Evaluated at century T: value = value0 + rate * T
function orbitalElementsAt(rates, T) {
    return {
        L: normalizeAngle(rates.L0 + rates.dL * T),
        a: rates.a0 + rates.da * T,
        e: rates.e0 + rates.de * T,
        I: rates.I0 + rates.dI * T,
        omega: rates.omega0 + rates.dOmega * T,
        pi: rates.pi0 + rates.dPi * T,
    };
}

// JPL approximate planetary positions (Standish 1992, valid 3000 BC - 3000 AD)
const planetaryElements = {
    mercury: {
        L0: 252.25032350, dL: 149472.67411175,
        a0: 0.38709927, da: 0.00000037,
        e0: 0.20563593, de: 0.00001906,
        I0: 7.00497902, dI: -0.00594749,
        omega0: 48.33076593, dOmega: -0.12534081,
        pi0: 77.45779628, dPi: 0.16047689,
    },
    venus: {
        L0: 181.97909950, dL: 58517.81538729,
        a0: 0.72333566, da: 0.00000390,
        e0: 0.00677672, de: -0.00004107,
        I0: 3.39467605, dI: -0.00078890,
        omega0: 76.67984255, dOmega: -0.27769418,
        pi0: 131.60246718, dPi: 0.00268329,
    },
    mars: {
        L0: 355.44656795, dL: 19140.30268499,
        a0: 1.52371034, da: 0.00001847,
        e0: 0.09339410, de: 0.00007882,
        I0: 1.84969142, dI: -0.00813131,
        omega0: 49.55953891, dOmega: -0.29257343,
        pi0: 336.05637041, dPi: 0.44441088,
    },
    jupiter: {
        L0: 34.39644051, dL: 3034.74612775,
        a0: 5.20288700, da: -0.00011607,
        e0: 0.04838624, de: -0.00013253,
        I0: 1.30439695, dI: -0.00183714,
        omega0: 100.47390909, dOmega: 0.20469106,
        pi0: 14.72847983, dPi: 0.21252668,
    },
    saturn: {
        L0: 49.95424423, dL: 1222.49362201,
        a0: 9.53667594, da: -0.00125060,
        e0: 0.05386179, de: -0.00050991,
        I0: 2.48599187, dI: 0.00193609,
        omega0: 113.66242448, dOmega: -0.28867794,
        pi0: 92.59887831, dPi: -0.41897216,
    },
    uranus: {
        L0: 313.23810451, dL: 428.48202785,
        a0: 19.18916464, da: -0.00196176,
        e0: 0.04725744, de: -0.00004397,
        I0: 0.77263783, dI: -0.00242939,
        omega0: 74.01692503, dOmega: 0.04240589,
        pi0: 170.95427630, dPi: 0.40805281,
    },
    neptune: {
        L0: 304.87997031, dL: 218.45945325,
        a0: 30.06992276, da: 0.00026291,
        e0: 0.00859048, de: 0.00005105,
        I0: 1.77004347, dI: 0.00035372,
        omega0: 131.78422574, dOmega: -0.00508664,
        pi0: 44.96476227, dPi: -0.32241464,
    },
    pluto: {
        L0: 238.92903833, dL: 145.20780515,
        a0: 39.48211675, da: -0.00031596,
        e0: 0.24882730, de: 0.00005170,
        I0: 17.14001206, dI: 0.00004818,
        omega0: 110.30393684, dOmega: -0.01183482,
        pi0: 224.06891629, dPi: -0.04062942,
    },
};

// Earth's elements (needed to convert heliocentric -> geocentric)
const earthElements = {
    L0: 100.46457166, dL: 35999.37244981,
    a0: 1.00000261, da: 0.00000562,
    e0: 0.01671123, de: -0.00004392,
    I0: -0.00001531, dI: -0.01294668,
    omega0: 0.0, dOmega: 0.0,
    pi0: 102.93768193, dPi: 0.32327364,
};

// Solve Kepler's equation: M = E - e*sin(E), return E in radians
function solveKepler(M, e) {
    const Mrad = M * deg2rad;
    let E = Mrad + e * Math.sin(Mrad);
    for (let i = 0; i < 30; i++) {
        const dE = (Mrad - (E - e * Math.sin(E))) / (1.0 - e * Math.cos(E));
        E += dE;
        if (Math.abs(dE) < 1e-12) break;
    }
    return E;
}

// Compute heliocentric ecliptic Cartesian coordinates from orbital elements
function heliocentricPosition(elems) {
    const M = normalizeAngle(elems.L - elems.pi);
    const E = solveKepler(M, elems.e);

    // True anomaly
    const sinE = Math.sin(E);
    const cosE = Math.cos(E);
    const nu = Math.atan2(Math.sqrt(1 - elems.e * elems.e) * sinE, cosE - elems.e);

    // Heliocentric distance
    const r = elems.a * (1 - elems.e * cosE);

    // Argument of perihelion
    const w = (elems.pi - elems.omega) * deg2rad;
    const omegaRad = elems.omega * deg2rad;
    const IRad = elems.I * deg2rad;

    // Position in orbital plane
    const cosNuW = Math.cos(nu + w);
    const sinNuW = Math.sin(nu + w);
    const cosOmega = Math.cos(omegaRad);
    const sinOmega = Math.sin(omegaRad);
    const cosI = Math.cos(IRad);
    const sinI = Math.sin(IRad);

    const x = r * (cosOmega * cosNuW - sinOmega * sinNuW * cosI);
    const y = r * (sinOmega * cosNuW + cosOmega * sinNuW * cosI);
    const z = r * (sinNuW * sinI);

    return { x, y, z };
}

const PlanetCalculator = {
    geocentricLongitude(body, jd) {
        const T = JulianDate.centuriesFromJ2000(jd);

        const rates = planetaryElements[body];
        if (!rates) return 0;
        const elems = orbitalElementsAt(rates, T);
        const earthElems = orbitalElementsAt(earthElements, T);

        const planet = heliocentricPosition(elems);
        const earth = heliocentricPosition(earthElems);

        const dx = planet.x - earth.x;
        const dy = planet.y - earth.y;

        return normalizeAngle(atan2Deg(dy, dx));
    },

    isRetrograde(body, jd) {
        const lon1 = PlanetCalculator.geocentricLongitude(body, jd - 1);
        const lon2 = PlanetCalculator.geocentricLongitude(body, jd + 1);
        let diff = lon2 - lon1;
        if (diff > 180) diff -= 360;
        if (diff < -180) diff += 360;
        return diff < 0;
    }
};

// MARK: - North Node (Mean)

const NorthNodeCalculator = {
    longitude(jd) {
        const T = JulianDate.centuriesFromJ2000(jd);
        return normalizeAngle(125.04452 - 1934.136261 * T +
                              0.0020708 * T * T + T * T * T / 450000.0);
    }
};

// MARK: - Ascendant & Midheaven

const AnglesCalculator = {
    calculate(jd, latitude, longitude) {
        const T = JulianDate.centuriesFromJ2000(jd);
        const eps = meanObliquity(T);
        const nut = nutation(T);
        const trueObliquity = eps + nut.obliquity;

        const lst = localSiderealTime(jd, longitude);

        // Midheaven (MC)
        const mc = normalizeAngle(atan2Deg(sinDeg(lst), cosDeg(lst) * cosDeg(trueObliquity)));

        // Ascendant
        const latRad = latitude * deg2rad;
        const epsRad = trueObliquity * deg2rad;
        const lstRad = lst * deg2rad;

        const ascRad = Math.atan2(
            -Math.cos(lstRad),
            Math.sin(lstRad) * Math.cos(epsRad) + Math.tan(latRad) * Math.sin(epsRad)
        );
        let asc = normalizeAngle(ascRad * rad2deg);

        // Correct atan2 quadrant ambiguity: ASC must be on the opposite
        // side of the ecliptic from MC (roughly MC + 90..270).
        // If atan2 gave the Descendant instead, flip by 180.
        if (normalizeAngle(asc - mc) > 180.0) {
            asc = normalizeAngle(asc + 180.0);
        }

        return { ascendant: asc, midheaven: mc };
    }
};

// MARK: - Placidus House Cusps

const PlacidusCalculator = {
    /**
     * Calculate all 12 Placidus house cusps (ecliptic longitudes, 0-360).
     * Index 0 = House 1 (ASC), index 9 = House 10 (MC), etc.
     */
    houseCusps(ascendant, midheaven, obliquity, latitude, ramc) {
        const cusps = new Array(12).fill(0);

        // Fixed cusps from angles
        cusps[0] = ascendant;                                // House 1 = ASC
        cusps[3] = normalizeAngle(midheaven + 180.0);        // House 4 = IC
        cusps[6] = normalizeAngle(ascendant + 180.0);        // House 7 = DESC
        cusps[9] = midheaven;                                // House 10 = MC

        // Intermediate cusps via iterative Placidus method
        // Above horizon: houses 11, 12 (fractions 1/3 and 2/3 of diurnal semi-arc from MC)
        cusps[10] = PlacidusCalculator._iterateCusp(ramc, obliquity, latitude, 1.0 / 3.0, true);
        cusps[11] = PlacidusCalculator._iterateCusp(ramc, obliquity, latitude, 2.0 / 3.0, true);

        // Below horizon: houses 2, 3 (fractions 1/3 and 2/3 of nocturnal semi-arc from IC)
        cusps[1] = PlacidusCalculator._iterateCusp(ramc, obliquity, latitude, 1.0 / 3.0, false);
        cusps[2] = PlacidusCalculator._iterateCusp(ramc, obliquity, latitude, 2.0 / 3.0, false);

        // Opposite cusps
        cusps[4] = normalizeAngle(cusps[10] + 180.0);   // House 5 opposite House 11
        cusps[5] = normalizeAngle(cusps[11] + 180.0);   // House 6 opposite House 12
        cusps[7] = normalizeAngle(cusps[1] + 180.0);    // House 8 opposite House 2
        cusps[8] = normalizeAngle(cusps[2] + 180.0);    // House 9 opposite House 3

        return cusps;
    },

    /**
     * Iteratively find the ecliptic longitude for a Placidus cusp.
     */
    _iterateCusp(ramc, obliquity, latitude, fraction, aboveHorizon) {
        const epsRad = obliquity * deg2rad;
        const latRad = latitude * deg2rad;

        // Starting RA guess
        let ra;
        if (aboveHorizon) {
            ra = normalizeAngle(ramc + fraction * 90.0);
        } else {
            ra = normalizeAngle(ramc + 180.0 + fraction * 90.0);
        }

        for (let iter = 0; iter < 50; iter++) {
            // Convert RA to ecliptic longitude (point on ecliptic)
            const raRad = ra * deg2rad;
            const lonRad = Math.atan2(Math.sin(raRad), Math.cos(raRad) * Math.cos(epsRad));
            const lon = normalizeAngle(lonRad * rad2deg);

            // Declination of this ecliptic longitude
            const dec = Math.asin(Math.sin(epsRad) * Math.sin(lon * deg2rad));

            // Diurnal semi-arc
            const tanProd = Math.tan(latRad) * Math.tan(dec);
            let dsa;
            if (Math.abs(tanProd) >= 1.0) {
                dsa = tanProd > 0 ? 180.0 : 0.0;
            } else {
                dsa = Math.acos(-tanProd) * rad2deg;
            }

            const nsa = 180.0 - dsa;

            // Required RA for this cusp
            let requiredRA;
            if (aboveHorizon) {
                requiredRA = normalizeAngle(ramc + fraction * dsa);
            } else {
                requiredRA = normalizeAngle(ramc + 180.0 + fraction * nsa);
            }

            // Check convergence
            let diff = requiredRA - ra;
            if (diff > 180) diff -= 360;
            if (diff < -180) diff += 360;

            ra = normalizeAngle(requiredRA);

            if (Math.abs(diff) < 0.0001) {
                break;
            }
        }

        // Convert final RA to ecliptic longitude
        const raRad = ra * deg2rad;
        const lonRad = Math.atan2(Math.sin(raRad), Math.cos(raRad) * Math.cos(epsRad));
        return normalizeAngle(lonRad * rad2deg);
    }
};

// MARK: - Zodiac helpers

const ZODIAC_SIGNS = [
    'aries', 'taurus', 'gemini', 'cancer', 'leo', 'virgo',
    'libra', 'scorpio', 'sagittarius', 'capricorn', 'aquarius', 'pisces'
];

function signFromLongitude(longitude) {
    let normalized = longitude % 360.0;
    if (normalized < 0) normalized += 360.0;
    return ZODIAC_SIGNS[Math.floor(normalized / 30.0) % 12];
}

function degreeInSign(longitude) {
    let deg = longitude % 30.0;
    if (deg < 0) deg += 30.0;
    return deg;
}

// MARK: - Public Interface

const Ephemeris = {
    /**
     * Full chart calculation: positions, angles, and Placidus house cusps.
     * @param {Date} date - JavaScript Date object (UTC)
     * @param {number} latitude - Birth latitude in degrees
     * @param {number} longitude - Birth longitude in degrees
     * @returns {Object} { positions, ascendant, midheaven, houseCusps }
     */
    calculate(date, latitude, longitude) {
        const jd = JulianDate.fromJSDate(date);
        return Ephemeris.calculateJD(jd, latitude, longitude);
    },

    /**
     * Full chart calculation from Julian Date.
     */
    calculateJD(jd, latitude, longitude) {
        const positions = [];

        // Sun
        const sunResult = SunCalculator.position(jd);
        positions.push({
            body: 'sun', longitude: sunResult.longitude, latitude: 0, isRetrograde: false
        });

        // Moon
        const moonLon = MoonCalculator.longitude(jd);
        positions.push({
            body: 'moon', longitude: moonLon, latitude: 0, isRetrograde: false
        });

        // Planets
        const planets = ['mercury', 'venus', 'mars', 'jupiter', 'saturn', 'uranus', 'neptune', 'pluto'];
        for (const planet of planets) {
            const lon = PlanetCalculator.geocentricLongitude(planet, jd);
            const retro = PlanetCalculator.isRetrograde(planet, jd);
            positions.push({
                body: planet, longitude: lon, latitude: 0, isRetrograde: retro
            });
        }

        // North Node
        const nnLon = NorthNodeCalculator.longitude(jd);
        positions.push({
            body: 'northNode', longitude: nnLon, latitude: 0, isRetrograde: true
        });

        // Angles
        const angles = AnglesCalculator.calculate(jd, latitude, longitude);

        // Placidus house cusps
        const T = JulianDate.centuriesFromJ2000(jd);
        const eps = meanObliquity(T);
        const nut = nutation(T);
        const trueObliquity = eps + nut.obliquity;
        const lst = localSiderealTime(jd, longitude);

        const cusps = PlacidusCalculator.houseCusps(
            angles.ascendant, angles.midheaven,
            trueObliquity, latitude, lst
        );

        return {
            positions,
            ascendant: angles.ascendant,
            midheaven: angles.midheaven,
            houseCusps: cusps,
        };
    },

    /**
     * Current sky positions (no houses/angles).
     * @returns {Array} Array of position objects
     */
    currentPositions() {
        const jd = JulianDate.fromJSDate(new Date());
        const positions = [];

        const sunResult = SunCalculator.position(jd);
        positions.push({
            body: 'sun', longitude: sunResult.longitude, latitude: 0, isRetrograde: false
        });

        const moonLon = MoonCalculator.longitude(jd);
        positions.push({
            body: 'moon', longitude: moonLon, latitude: 0, isRetrograde: false
        });

        const planets = ['mercury', 'venus', 'mars', 'jupiter', 'saturn', 'uranus', 'neptune', 'pluto'];
        for (const planet of planets) {
            const lon = PlanetCalculator.geocentricLongitude(planet, jd);
            const retro = PlanetCalculator.isRetrograde(planet, jd);
            positions.push({
                body: planet, longitude: lon, latitude: 0, isRetrograde: retro
            });
        }

        const nnLon = NorthNodeCalculator.longitude(jd);
        positions.push({
            body: 'northNode', longitude: nnLon, latitude: 0, isRetrograde: true
        });

        return positions;
    },

    // Expose sub-calculators and helpers for advanced use
    JulianDate,
    SunCalculator,
    MoonCalculator,
    PlanetCalculator,
    NorthNodeCalculator,
    AnglesCalculator,
    PlacidusCalculator,
    normalizeAngle,
    signFromLongitude,
    degreeInSign,
    meanObliquity,
    nutation,
    greenwichMeanSiderealTime,
    localSiderealTime,
};

export { Ephemeris };
export default Ephemeris;
