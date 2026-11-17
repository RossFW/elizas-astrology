// chart-engine.js — Chart calculation, aspects, transits, synastry
// Ported from ChartEngine.swift. Uses ephemeris.js for astronomical calculations.

import { Ephemeris } from './ephemeris.js';

// MARK: - Constants

const ZODIAC_SIGNS = [
    'aries', 'taurus', 'gemini', 'cancer', 'leo', 'virgo',
    'libra', 'scorpio', 'sagittarius', 'capricorn', 'aquarius', 'pisces'
];

const ZODIAC_SYMBOLS = {
    aries: '\u2648', taurus: '\u2649', gemini: '\u264A', cancer: '\u264B',
    leo: '\u264C', virgo: '\u264D', libra: '\u264E', scorpio: '\u264F',
    sagittarius: '\u2650', capricorn: '\u2651', aquarius: '\u2652', pisces: '\u2653',
};

const BODY_SYMBOLS = {
    sun: '\u2609', moon: '\u263D', mercury: '\u263F', venus: '\u2640',
    mars: '\u2642', jupiter: '\u2643', saturn: '\u2644', uranus: '\u2645',
    neptune: '\u2646', pluto: '\u2647', northNode: '\u260A',
};

const BODY_NAMES = {
    sun: 'Sun', moon: 'Moon', mercury: 'Mercury', venus: 'Venus',
    mars: 'Mars', jupiter: 'Jupiter', saturn: 'Saturn', uranus: 'Uranus',
    neptune: 'Neptune', pluto: 'Pluto', northNode: 'North Node',
};

const ELEMENT_MAP = {
    aries: 'fire', leo: 'fire', sagittarius: 'fire',
    taurus: 'earth', virgo: 'earth', capricorn: 'earth',
    gemini: 'air', libra: 'air', aquarius: 'air',
    cancer: 'water', scorpio: 'water', pisces: 'water',
};

const MODALITY_MAP = {
    aries: 'cardinal', cancer: 'cardinal', libra: 'cardinal', capricorn: 'cardinal',
    taurus: 'fixed', leo: 'fixed', scorpio: 'fixed', aquarius: 'fixed',
    gemini: 'mutable', virgo: 'mutable', sagittarius: 'mutable', pisces: 'mutable',
};

const RULING_BODY = {
    aries: 'mars', taurus: 'venus', gemini: 'mercury', cancer: 'moon',
    leo: 'sun', virgo: 'mercury', libra: 'venus', scorpio: 'pluto',
    sagittarius: 'jupiter', capricorn: 'saturn', aquarius: 'uranus', pisces: 'neptune',
};

// MARK: - Aspect Types

const AspectType = {
    conjunction: { name: 'Conjunction', angle: 0, orb: 8, symbol: '\u260C', isHarmonious: true, briefDescription: 'merging energy' },
    sextile:     { name: 'Sextile',     angle: 60, orb: 6, symbol: '\u26B9', isHarmonious: true, briefDescription: 'opportunity and flow' },
    square:      { name: 'Square',       angle: 90, orb: 7, symbol: '\u25A1', isHarmonious: false, briefDescription: 'tension and growth' },
    trine:       { name: 'Trine',        angle: 120, orb: 8, symbol: '\u25B3', isHarmonious: true, briefDescription: 'harmony and ease' },
    opposition:  { name: 'Opposition',   angle: 180, orb: 8, symbol: '\u260D', isHarmonious: false, briefDescription: 'balancing opposites' },
};

const ASPECT_TYPES = ['conjunction', 'sextile', 'square', 'trine', 'opposition'];

// MARK: - Body classification helpers

function isPersonal(body) {
    return body === 'sun' || body === 'moon' || body === 'mercury' || body === 'venus' || body === 'mars';
}

function isSocial(body) {
    return body === 'jupiter' || body === 'saturn';
}

function isOuter(body) {
    return body === 'uranus' || body === 'neptune' || body === 'pluto';
}

// MARK: - Position helpers

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

function formattedDegree(position) {
    const sign = signFromLongitude(position.longitude);
    const dis = degreeInSign(position.longitude);
    const deg = Math.floor(dis);
    const min = Math.floor((dis - deg) * 60);
    return `${deg}\u00B0${min}' ${sign.charAt(0).toUpperCase() + sign.slice(1)}`;
}

function formattedShort(position) {
    const bodySymbol = BODY_SYMBOLS[position.body] || position.body;
    const signSymbol = ZODIAC_SYMBOLS[signFromLongitude(position.longitude)] || '';
    return `${bodySymbol} ${signSymbol} ${Math.floor(degreeInSign(position.longitude))}\u00B0`;
}

// MARK: - House determination

/**
 * Determine which Placidus house (1-12) a longitude falls in.
 * @param {number} longitude - Ecliptic longitude (0-360)
 * @param {number[]} houseCusps - Array of 12 cusp longitudes (index 0 = House 1)
 * @returns {number} House number 1-12
 */
function houseForLongitude(longitude, houseCusps) {
    if (!houseCusps || houseCusps.length !== 12) return 1;
    for (let i = 0; i < 12; i++) {
        const next = (i + 1) % 12;
        const cuspStart = houseCusps[i];
        const cuspEnd = houseCusps[next];

        if (cuspStart <= cuspEnd) {
            if (longitude >= cuspStart && longitude < cuspEnd) return i + 1;
        } else {
            // Wraps around 0 degrees
            if (longitude >= cuspStart || longitude < cuspEnd) return i + 1;
        }
    }
    return 1;
}

// MARK: - Aspect Calculator

const AspectCalculator = {
    /**
     * Find natal aspects between positions.
     * @param {Object[]} positions - Array of { body, longitude, ... }
     * @param {Object} [orbs] - Optional custom orbs { conjunction: N, ... }
     * @returns {Object[]} Array of aspect objects
     */
    findAspects(positions, orbs) {
        const aspects = [];

        for (let i = 0; i < positions.length; i++) {
            for (let j = i + 1; j < positions.length; j++) {
                const p1 = positions[i];
                const p2 = positions[j];

                // Skip North Node aspects for simplicity
                if (p1.body === 'northNode' || p2.body === 'northNode') continue;

                const aspect = AspectCalculator._checkAspect(p1, p2, orbs);
                if (aspect) aspects.push(aspect);
            }
        }

        return aspects;
    },

    /**
     * Find aspects between two sets of positions (transit-to-natal or synastry).
     */
    findAspectsBetween(transitPositions, natalPositions, orbs) {
        const aspects = [];
        for (const tp of transitPositions) {
            if (tp.body === 'northNode') continue;
            for (const np of natalPositions) {
                if (np.body === 'northNode') continue;
                const aspect = AspectCalculator._checkAspect(tp, np, orbs);
                if (aspect) aspects.push(aspect);
            }
        }
        return aspects;
    },

    _checkAspect(pos1, pos2, orbs) {
        let diff = Math.abs(pos1.longitude - pos2.longitude);
        if (diff > 180) diff = 360 - diff;

        for (const typeName of ASPECT_TYPES) {
            const aspectDef = AspectType[typeName];
            const maxOrb = (orbs && orbs[typeName] !== undefined) ? orbs[typeName] : aspectDef.orb;
            const orb = Math.abs(diff - aspectDef.angle);
            if (orb <= maxOrb) {
                return {
                    body1: pos1.body,
                    body2: pos2.body,
                    type: typeName,
                    orb: orb,
                    isApplying: true, // simplified for now
                };
            }
        }
        return null;
    }
};

// MARK: - Transit Engine

const TransitEngine = {
    /**
     * Find current transits to a natal chart.
     * @param {Object} chart - NatalChart object from calculateChart
     * @returns {Object[]} Array of transit objects
     */
    currentTransits(chart) {
        const currentPositions = Ephemeris.currentPositions();
        return TransitEngine._findTransits(currentPositions, chart);
    },

    /**
     * Generate a weekly transit report.
     * @param {Object} chart - NatalChart object
     * @param {number} [latitude=0] - Observer latitude
     * @param {number} [longitude=0] - Observer longitude
     * @returns {Object} WeeklyTransitReport
     */
    weeklyReport(chart, latitude = 0, longitude = 0) {
        const now = new Date();

        // Find start of current week (Monday)
        const weekStart = new Date(now);
        // getDay(): 0=Sun, 1=Mon, ..., 6=Sat
        const dayOfWeek = weekStart.getDay();
        const daysToMonday = dayOfWeek === 0 ? 6 : dayOfWeek - 1;
        weekStart.setDate(weekStart.getDate() - daysToMonday);
        weekStart.setHours(0, 0, 0, 0);

        const weekEnd = new Date(weekStart);
        weekEnd.setDate(weekEnd.getDate() + 7);

        // Midweek snapshot for transits
        const midweek = new Date(weekStart);
        midweek.setDate(midweek.getDate() + 3);

        const jd = Ephemeris.JulianDate.fromJSDate(midweek);
        const midweekResult = Ephemeris.calculateJD(jd, latitude, longitude);
        const transitPositions = midweekResult.positions;

        const transits = TransitEngine._findTransits(transitPositions, chart);

        // Current retrogrades
        const retrogrades = TransitEngine._findRetrogrades(transitPositions, chart);

        // Current moon sign
        const currentPositions = Ephemeris.currentPositions();
        const moonPos = currentPositions.find(p => p.body === 'moon');
        const currentMoonSign = moonPos ? signFromLongitude(moonPos.longitude) : 'aries';

        // Sort transits by significance
        const sortedTransits = [...transits].sort((a, b) => b.significance - a.significance);

        return {
            transits: sortedTransits,
            retrogrades,
            currentMoonSign,
            weekStart,
            weekEnd,
            // Convenience accessors matching Swift API
            significantTransits: sortedTransits,
            topTransits: sortedTransits.slice(0, 5),
        };
    },

    _findTransits(transitPositions, chart) {
        const transits = [];

        // Use tighter orbs for transits than natal aspects
        const transitOrbs = {
            conjunction: 5,
            opposition: 5,
            trine: 4,
            square: 4,
            sextile: 3,
        };

        for (const tp of transitPositions) {
            if (tp.body === 'northNode') continue;
            for (const np of chart.positions) {
                if (np.body === 'northNode') continue;
                // Skip Moon transiting Moon (too brief to matter)
                if (tp.body === 'moon' && np.body === 'moon') continue;

                let diff = Math.abs(tp.longitude - np.longitude);
                if (diff > 180) diff = 360 - diff;

                for (const typeName of ASPECT_TYPES) {
                    const aspectDef = AspectType[typeName];
                    const maxOrb = transitOrbs[typeName] !== undefined ? transitOrbs[typeName] : aspectDef.orb;
                    const orb = Math.abs(diff - aspectDef.angle);
                    if (orb <= maxOrb) {
                        const house = houseForLongitude(np.longitude, chart.houseCusps);
                        const significance = TransitEngine._calcSignificance(tp, np, typeName, orb);
                        transits.push({
                            transitingPosition: tp,
                            natalPosition: np,
                            aspectType: typeName,
                            orb,
                            isApplying: true,
                            houseAffected: house,
                            significance,
                        });
                    }
                }
            }
        }

        return transits;
    },

    _calcSignificance(transitPos, natalPos, aspectType, orb) {
        let score = 0;
        if (isOuter(transitPos.body)) score += 3;
        if (isSocial(transitPos.body)) score += 2;
        if (isPersonal(natalPos.body)) score += 2;
        if (natalPos.body === 'sun' || natalPos.body === 'moon') score += 1;
        if (aspectType === 'conjunction' || aspectType === 'opposition') score += 1;
        const orbScore = Math.max(0, Math.floor(5 - orb));
        score += orbScore;
        return score;
    },

    _findRetrogrades(positions, chart) {
        return positions
            .filter(pos => pos.isRetrograde && pos.body !== 'northNode')
            .map(pos => ({
                body: pos.body,
                sign: signFromLongitude(pos.longitude),
                houseInChart: houseForLongitude(pos.longitude, chart.houseCusps),
            }));
    }
};

// MARK: - Synastry Calculator

const SynastryCalculator = {
    /**
     * Compare two natal charts for compatibility.
     * @param {Object} chart1 - First natal chart
     * @param {Object} chart2 - Second natal chart
     * @returns {Object} SynastryReport { aspects, overallHarmony, harmonious, challenging }
     */
    compare(chart1, chart2) {
        const aspects = AspectCalculator.findAspectsBetween(
            chart1.positions,
            chart2.positions
        );

        // Calculate harmony score
        let score = 50.0;
        for (const aspect of aspects) {
            const weight = 1.0 / Math.max(aspect.orb, 0.5); // tighter orbs count more
            const def = AspectType[aspect.type];
            if (def && def.isHarmonious) {
                score += weight * 3;
            } else {
                score -= weight * 2;
            }
        }
        const overallHarmony = Math.min(100, Math.max(0, score));

        const harmonious = aspects.filter(a => AspectType[a.type] && AspectType[a.type].isHarmonious);
        const challenging = aspects.filter(a => AspectType[a.type] && !AspectType[a.type].isHarmonious);

        return {
            aspects,
            overallHarmony,
            harmonious,
            challenging,
        };
    }
};

// MARK: - Chart Calculator (main entry point)

const ChartCalculator = {
    /**
     * Calculate a full natal chart.
     * @param {Date} date - Birth date/time as JS Date (UTC)
     * @param {number} latitude - Birth latitude
     * @param {number} longitude - Birth longitude
     * @returns {Object} NatalChart object
     */
    calculateChart(date, latitude, longitude) {
        const result = Ephemeris.calculate(date, latitude, longitude);
        const aspects = AspectCalculator.findAspects(result.positions);

        // Enrich positions with sign info
        const positions = result.positions.map(pos => ({
            ...pos,
            sign: signFromLongitude(pos.longitude),
            degreeInSign: degreeInSign(pos.longitude),
            formattedDegree: formattedDegree(pos),
            formattedShort: formattedShort(pos),
        }));

        const chart = {
            positions,
            ascendantLongitude: result.ascendant,
            midheavenLongitude: result.midheaven,
            aspects,
            houseCusps: result.houseCusps,

            // Derived properties
            ascendantSign: signFromLongitude(result.ascendant),
            midheavenSign: signFromLongitude(result.midheaven),
            sunSign: signFromLongitude((positions.find(p => p.body === 'sun') || {}).longitude || 0),
            moonSign: signFromLongitude((positions.find(p => p.body === 'moon') || {}).longitude || 0),
            risingSign: signFromLongitude(result.ascendant),
        };

        // Attach helper methods
        chart.position = function(body) {
            return this.positions.find(p => p.body === body) || null;
        };

        chart.house = function(longitude) {
            return houseForLongitude(longitude, this.houseCusps);
        };

        chart.houseForBody = function(body) {
            const pos = this.position(body);
            if (!pos) return 1;
            return houseForLongitude(pos.longitude, this.houseCusps);
        };

        chart.cusp = function(houseNum) {
            if (!this.houseCusps || this.houseCusps.length !== 12) return 0;
            return this.houseCusps[(houseNum - 1) % 12];
        };

        return chart;
    }
};

// MARK: - Public Export

const ChartEngine = {
    // Main calculator
    calculateChart: ChartCalculator.calculateChart.bind(ChartCalculator),

    // Sub-engines
    AspectCalculator,
    TransitEngine,
    SynastryCalculator,

    // Aspect type definitions
    AspectType,
    ASPECT_TYPES,

    // Zodiac data
    ZODIAC_SIGNS,
    ZODIAC_SYMBOLS,
    BODY_SYMBOLS,
    BODY_NAMES,
    ELEMENT_MAP,
    MODALITY_MAP,
    RULING_BODY,

    // Helper functions
    signFromLongitude,
    degreeInSign,
    formattedDegree,
    formattedShort,
    houseForLongitude,
    isPersonal,
    isSocial,
    isOuter,
};

export { ChartEngine };
export default ChartEngine;
