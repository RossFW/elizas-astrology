import Foundation

// MARK: - Math Helpers

private let deg2rad = Double.pi / 180.0
private let rad2deg = 180.0 / Double.pi

private nonisolated func normalizeAngle(_ angle: Double) -> Double {
    var a = angle.truncatingRemainder(dividingBy: 360.0)
    if a < 0 { a += 360.0 }
    return a
}

private nonisolated func sinDeg(_ deg: Double) -> Double { sin(deg * deg2rad) }
private nonisolated func cosDeg(_ deg: Double) -> Double { cos(deg * deg2rad) }
private nonisolated func tanDeg(_ deg: Double) -> Double { tan(deg * deg2rad) }
private nonisolated func asinDeg(_ x: Double) -> Double { asin(x) * rad2deg }
private nonisolated func atan2Deg(_ y: Double, _ x: Double) -> Double { atan2(y, x) * rad2deg }

// MARK: - Julian Date

nonisolated enum JulianDate {
    static func fromDate(year: Int, month: Int, day: Double) -> Double {
        var y = Double(year)
        var m = Double(month)
        if m <= 2 {
            y -= 1
            m += 12
        }
        let A = floor(y / 100.0)
        let B = 2 - A + floor(A / 4.0)
        return floor(365.25 * (y + 4716)) + floor(30.6001 * (m + 1)) + day + B - 1524.5
    }

    static func fromDate(_ date: Date) -> Double {
        var cal = Calendar(identifier: .gregorian)
        cal.timeZone = TimeZone(identifier: "UTC")!
        let comps = cal.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date)
        let day = Double(comps.day ?? 1) +
            Double(comps.hour ?? 0) / 24.0 +
            Double(comps.minute ?? 0) / 1440.0 +
            Double(comps.second ?? 0) / 86400.0
        return fromDate(year: comps.year ?? 2000, month: comps.month ?? 1, day: day)
    }

    static func centuriesFromJ2000(_ jd: Double) -> Double {
        (jd - 2451545.0) / 36525.0
    }
}

// MARK: - Obliquity of Ecliptic

private nonisolated func meanObliquity(T: Double) -> Double {
    23.439291 - 0.0130042 * T - 1.64e-7 * T * T + 5.04e-7 * T * T * T
}

// MARK: - Nutation

private nonisolated func nutation(T: Double) -> (longitude: Double, obliquity: Double) {
    let omega = 125.04452 - 1934.136261 * T
    let L0 = 280.4665 + 36000.7698 * T
    let Lp = 218.3165 + 481267.8813 * T
    let dPsi = -17.2 / 3600.0 * sinDeg(omega) - 1.32 / 3600.0 * sinDeg(2 * L0) -
               0.23 / 3600.0 * sinDeg(2 * Lp) + 0.21 / 3600.0 * sinDeg(2 * omega)
    let dEps = 9.2 / 3600.0 * cosDeg(omega) + 0.57 / 3600.0 * cosDeg(2 * L0) +
               0.10 / 3600.0 * cosDeg(2 * Lp) - 0.09 / 3600.0 * cosDeg(2 * omega)
    return (dPsi, dEps)
}

// MARK: - Sidereal Time

private nonisolated func greenwichMeanSiderealTime(jd: Double) -> Double {
    let T = JulianDate.centuriesFromJ2000(jd)
    let gmst = 280.46061837 + 360.98564736629 * (jd - 2451545.0) +
               0.000387933 * T * T - T * T * T / 38710000.0
    return normalizeAngle(gmst)
}

private nonisolated func localSiderealTime(jd: Double, longitude: Double) -> Double {
    normalizeAngle(greenwichMeanSiderealTime(jd: jd) + longitude)
}

// MARK: - Sun Position (Meeus Ch. 25)

nonisolated enum SunCalculator {
    static func position(jd: Double) -> (longitude: Double, meanAnomaly: Double) {
        let T = JulianDate.centuriesFromJ2000(jd)
        let L0 = normalizeAngle(280.46646 + 36000.76983 * T + 0.0003032 * T * T)
        let M = normalizeAngle(357.52911 + 35999.05029 * T - 0.0001537 * T * T)
        let C = (1.914602 - 0.004817 * T - 0.000014 * T * T) * sinDeg(M) +
                (0.019993 - 0.000101 * T) * sinDeg(2 * M) +
                0.000289 * sinDeg(3 * M)
        let sunLon = L0 + C
        let omega = 125.04 - 1934.136 * T
        let apparent = sunLon - 0.00569 - 0.00478 * sinDeg(omega)
        return (normalizeAngle(apparent), M)
    }
}

// MARK: - Moon Position (Meeus Ch. 47)

nonisolated enum MoonCalculator {
    static func longitude(jd: Double) -> Double {
        let T = JulianDate.centuriesFromJ2000(jd)
        let Lp = normalizeAngle(218.3164477 + 481267.88123421 * T -
                                0.0015786 * T * T + T * T * T / 538841.0)
        let D = normalizeAngle(297.8501921 + 445267.1114034 * T -
                               0.0018819 * T * T + T * T * T / 545868.0)
        let M = normalizeAngle(357.5291092 + 35999.0502909 * T -
                               0.0001536 * T * T)
        let Mp = normalizeAngle(134.9633964 + 477198.8675055 * T +
                                0.0087414 * T * T + T * T * T / 69699.0)
        let F = normalizeAngle(93.2720950 + 483202.0175233 * T -
                               0.0036539 * T * T)

        let E = 1.0 - 0.002516 * T - 0.0000074 * T * T
        let E2 = E * E

        // Longitude terms: (D, M, Mp, F, coefficient)
        // M multiplier determines E correction: |M|=1 -> *E, |M|=2 -> *E^2
        let terms: [(Double, Double, Double, Double, Double)] = [
            (0, 0, 1, 0, 6288774),
            (2, 0, -1, 0, 1274027),
            (2, 0, 0, 0, 658314),
            (0, 0, 2, 0, 213618),
            (0, 1, 0, 0, -185116),
            (0, 0, 0, 2, -114332),
            (2, 0, -2, 0, 58793),
            (2, -1, -1, 0, 57066),
            (2, 0, 1, 0, 53322),
            (2, -1, 0, 0, 45758),
            (0, 1, -1, 0, -40923),
            (1, 0, 0, 0, -34720),
            (0, 1, 1, 0, -30383),
            (2, 0, 0, -2, 15327),
            (0, 0, 1, 2, -12528),
            (0, 0, 1, -2, 10980),
            (4, 0, -1, 0, 10675),
            (0, 0, 3, 0, 10034),
            (4, 0, -2, 0, 8548),
            (2, 1, -1, 0, -7888),
            (2, 1, 0, 0, -6766),
            (1, 0, -1, 0, -5163),
            (1, 1, 0, 0, 4987),
            (2, -1, 1, 0, 4036),
            (2, 0, 2, 0, 3994),
            (4, 0, 0, 0, 3861),
            (2, 0, -3, 0, 3665),
            (0, 1, -2, 0, -2689),
            (2, 0, -1, 2, -2602),
            (2, -1, -2, 0, 2390),
        ]

        var sumL = 0.0
        for (d, m, mp, f, coeff) in terms {
            let arg = d * D + m * M + mp * Mp + f * F
            var c = coeff
            let absM = abs(m)
            if absM == 1 { c *= E }
            else if absM == 2 { c *= E2 }
            sumL += c * sinDeg(arg)
        }

        // A1, A2 corrections
        let A1 = normalizeAngle(119.75 + 131.849 * T)
        let A2 = normalizeAngle(53.09 + 479264.290 * T)
        sumL += 3958 * sinDeg(A1) + 1962 * sinDeg(Lp - F) + 318 * sinDeg(A2)

        return normalizeAngle(Lp + sumL / 1000000.0)
    }
}

// MARK: - Planet Positions (Keplerian Elements + Kepler Equation)

private struct OrbitalElements: Sendable {
    let L: Double    // mean longitude (degrees)
    let a: Double    // semi-major axis (AU)
    let e: Double    // eccentricity
    let I: Double    // inclination (degrees)
    let omega: Double // longitude of ascending node (degrees)
    let pi: Double   // longitude of perihelion (degrees)
}

private struct OrbitalElementRates: Sendable {
    let L0: Double, dL: Double
    let a0: Double, da: Double
    let e0: Double, de: Double
    let I0: Double, dI: Double
    let omega0: Double, dOmega: Double
    let pi0: Double, dPi: Double

    nonisolated func at(T: Double) -> OrbitalElements {
        OrbitalElements(
            L: normalizeAngle(L0 + dL * T),
            a: a0 + da * T,
            e: e0 + de * T,
            I: I0 + dI * T,
            omega: omega0 + dOmega * T,
            pi: pi0 + dPi * T
        )
    }
}

// JPL approximate planetary positions (Standish 1992, valid 3000 BC - 3000 AD)
private let planetaryElements: [CelestialBody: OrbitalElementRates] = [
    .mercury: OrbitalElementRates(
        L0: 252.25032350, dL: 149472.67411175,
        a0: 0.38709927, da: 0.00000037,
        e0: 0.20563593, de: 0.00001906,
        I0: 7.00497902, dI: -0.00594749,
        omega0: 48.33076593, dOmega: -0.12534081,
        pi0: 77.45779628, dPi: 0.16047689
    ),
    .venus: OrbitalElementRates(
        L0: 181.97909950, dL: 58517.81538729,
        a0: 0.72333566, da: 0.00000390,
        e0: 0.00677672, de: -0.00004107,
        I0: 3.39467605, dI: -0.00078890,
        omega0: 76.67984255, dOmega: -0.27769418,
        pi0: 131.60246718, dPi: 0.00268329
    ),
    .mars: OrbitalElementRates(
        L0: 355.44656795, dL: 19140.30268499,
        a0: 1.52371034, da: 0.00001847,
        e0: 0.09339410, de: 0.00007882,
        I0: 1.84969142, dI: -0.00813131,
        omega0: 49.55953891, dOmega: -0.29257343,
        pi0: 336.05637041, dPi: 0.44441088
    ),
    .jupiter: OrbitalElementRates(
        L0: 34.39644051, dL: 3034.74612775,
        a0: 5.20288700, da: -0.00011607,
        e0: 0.04838624, de: -0.00013253,
        I0: 1.30439695, dI: -0.00183714,
        omega0: 100.47390909, dOmega: 0.20469106,
        pi0: 14.72847983, dPi: 0.21252668
    ),
    .saturn: OrbitalElementRates(
        L0: 49.95424423, dL: 1222.49362201,
        a0: 9.53667594, da: -0.00125060,
        e0: 0.05386179, de: -0.00050991,
        I0: 2.48599187, dI: 0.00193609,
        omega0: 113.66242448, dOmega: -0.28867794,
        pi0: 92.59887831, dPi: -0.41897216
    ),
    .uranus: OrbitalElementRates(
        L0: 313.23810451, dL: 428.48202785,
        a0: 19.18916464, da: -0.00196176,
        e0: 0.04725744, de: -0.00004397,
        I0: 0.77263783, dI: -0.00242939,
        omega0: 74.01692503, dOmega: 0.04240589,
        pi0: 170.95427630, dPi: 0.40805281
    ),
    .neptune: OrbitalElementRates(
        L0: 304.87997031, dL: 218.45945325,
        a0: 30.06992276, da: 0.00026291,
        e0: 0.00859048, de: 0.00005105,
        I0: 1.77004347, dI: 0.00035372,
        omega0: 131.78422574, dOmega: -0.00508664,
        pi0: 44.96476227, dPi: -0.32241464
    ),
    .pluto: OrbitalElementRates(
        L0: 238.92903833, dL: 145.20780515,
        a0: 39.48211675, da: -0.00031596,
        e0: 0.24882730, de: 0.00005170,
        I0: 17.14001206, dI: 0.00004818,
        omega0: 110.30393684, dOmega: -0.01183482,
        pi0: 224.06891629, dPi: -0.04062942
    ),
]

// Earth's elements (needed to convert heliocentric → geocentric)
private let earthElements = OrbitalElementRates(
    L0: 100.46457166, dL: 35999.37244981,
    a0: 1.00000261, da: 0.00000562,
    e0: 0.01671123, de: -0.00004392,
    I0: -0.00001531, dI: -0.01294668,
    omega0: 0.0, dOmega: 0.0,
    pi0: 102.93768193, dPi: 0.32327364
)

// Solve Kepler's equation: M = E - e*sin(E), return E in radians
private nonisolated func solveKepler(M: Double, e: Double) -> Double {
    let Mrad = M * deg2rad
    var E = Mrad + e * sin(Mrad)
    for _ in 0..<30 {
        let dE = (Mrad - (E - e * sin(E))) / (1.0 - e * cos(E))
        E += dE
        if abs(dE) < 1e-12 { break }
    }
    return E
}

// Compute heliocentric ecliptic Cartesian coordinates from orbital elements
private nonisolated func heliocentricPosition(_ elems: OrbitalElements) -> (x: Double, y: Double, z: Double) {
    let M = normalizeAngle(elems.L - elems.pi)
    let E = solveKepler(M: M, e: elems.e)

    // True anomaly
    let sinE = sin(E)
    let cosE = cos(E)
    let nu = atan2(sqrt(1 - elems.e * elems.e) * sinE, cosE - elems.e)

    // Heliocentric distance
    let r = elems.a * (1 - elems.e * cosE)

    // Argument of perihelion
    let w = (elems.pi - elems.omega) * deg2rad
    let omegaRad = elems.omega * deg2rad
    let IRad = elems.I * deg2rad

    // Position in orbital plane
    let cosNuW = cos(nu + w)
    let sinNuW = sin(nu + w)
    let cosOmega = cos(omegaRad)
    let sinOmega = sin(omegaRad)
    let cosI = cos(IRad)
    let sinI = sin(IRad)

    let x = r * (cosOmega * cosNuW - sinOmega * sinNuW * cosI)
    let y = r * (sinOmega * cosNuW + cosOmega * sinNuW * cosI)
    let z = r * (sinNuW * sinI)

    return (x, y, z)
}

nonisolated enum PlanetCalculator {
    static func geocentricLongitude(body: CelestialBody, jd: Double) -> Double {
        let T = JulianDate.centuriesFromJ2000(jd)

        guard let rates = planetaryElements[body] else { return 0 }
        let elems = rates.at(T: T)
        let earthElems = earthElements.at(T: T)

        let planet = heliocentricPosition(elems)
        let earth = heliocentricPosition(earthElems)

        let dx = planet.x - earth.x
        let dy = planet.y - earth.y

        return normalizeAngle(atan2Deg(dy, dx))
    }

    static func isRetrograde(body: CelestialBody, jd: Double) -> Bool {
        let lon1 = geocentricLongitude(body: body, jd: jd - 1)
        let lon2 = geocentricLongitude(body: body, jd: jd + 1)
        var diff = lon2 - lon1
        if diff > 180 { diff -= 360 }
        if diff < -180 { diff += 360 }
        return diff < 0
    }
}

// MARK: - North Node (Mean)

nonisolated enum NorthNodeCalculator {
    static func longitude(jd: Double) -> Double {
        let T = JulianDate.centuriesFromJ2000(jd)
        return normalizeAngle(125.04452 - 1934.136261 * T +
                              0.0020708 * T * T + T * T * T / 450000.0)
    }
}

// MARK: - Ascendant & Midheaven

nonisolated enum AnglesCalculator {
    static func calculate(jd: Double, latitude: Double, longitude: Double)
        -> (ascendant: Double, midheaven: Double)
    {
        let T = JulianDate.centuriesFromJ2000(jd)
        let eps = meanObliquity(T: T)
        let nut = nutation(T: T)
        let trueObliquity = eps + nut.obliquity

        let lst = localSiderealTime(jd: jd, longitude: longitude)

        // Midheaven (MC)
        let mc = normalizeAngle(atan2Deg(sinDeg(lst), cosDeg(lst) * cosDeg(trueObliquity)))

        // Ascendant
        let latRad = latitude * deg2rad
        let epsRad = trueObliquity * deg2rad
        let lstRad = lst * deg2rad

        let ascRad = atan2(
            -cos(lstRad),
            sin(lstRad) * cos(epsRad) + tan(latRad) * sin(epsRad)
        )
        var asc = normalizeAngle(ascRad * rad2deg)

        // Correct atan2 quadrant ambiguity: ASC must be on the opposite
        // side of the ecliptic from MC (roughly MC + 90°..270°).
        // If atan2 gave the Descendant instead, flip by 180°.
        if normalizeAngle(asc - mc) > 180.0 {
            asc = normalizeAngle(asc + 180.0)
        }

        return (asc, mc)
    }
}

// MARK: - Placidus House Cusps

nonisolated enum PlacidusCalculator {
    /// Calculate all 12 Placidus house cusps (ecliptic longitudes, 0-360°).
    /// Index 0 = House 1 (ASC), index 9 = House 10 (MC), etc.
    static func houseCusps(
        ascendant: Double, midheaven: Double,
        obliquity: Double, latitude: Double, ramc: Double
    ) -> [Double] {
        var cusps = Array(repeating: 0.0, count: 12)

        // Fixed cusps from angles
        cusps[0] = ascendant                                  // House 1 = ASC
        cusps[3] = normalizeAngle(midheaven + 180.0)          // House 4 = IC
        cusps[6] = normalizeAngle(ascendant + 180.0)          // House 7 = DESC
        cusps[9] = midheaven                                  // House 10 = MC

        // Intermediate cusps via iterative Placidus method
        // Above horizon: houses 11, 12 (fractions 1/3 and 2/3 of diurnal semi-arc from MC)
        cusps[10] = iterateCusp(ramc: ramc, obliquity: obliquity,
                                latitude: latitude, fraction: 1.0 / 3.0, aboveHorizon: true)
        cusps[11] = iterateCusp(ramc: ramc, obliquity: obliquity,
                                latitude: latitude, fraction: 2.0 / 3.0, aboveHorizon: true)

        // Below horizon: houses 2, 3 (fractions 1/3 and 2/3 of nocturnal semi-arc from IC)
        cusps[1] = iterateCusp(ramc: ramc, obliquity: obliquity,
                               latitude: latitude, fraction: 1.0 / 3.0, aboveHorizon: false)
        cusps[2] = iterateCusp(ramc: ramc, obliquity: obliquity,
                               latitude: latitude, fraction: 2.0 / 3.0, aboveHorizon: false)

        // Opposite cusps
        cusps[4] = normalizeAngle(cusps[10] + 180.0)   // House 5 opposite House 11
        cusps[5] = normalizeAngle(cusps[11] + 180.0)   // House 6 opposite House 12
        cusps[7] = normalizeAngle(cusps[1] + 180.0)    // House 8 opposite House 2
        cusps[8] = normalizeAngle(cusps[2] + 180.0)    // House 9 opposite House 3

        return cusps
    }

    /// Iteratively find the ecliptic longitude for a Placidus cusp.
    private static func iterateCusp(
        ramc: Double, obliquity: Double, latitude: Double,
        fraction: Double, aboveHorizon: Bool
    ) -> Double {
        let epsRad = obliquity * deg2rad
        let latRad = latitude * deg2rad

        // Starting RA guess
        var ra: Double
        if aboveHorizon {
            ra = normalizeAngle(ramc + fraction * 90.0)
        } else {
            ra = normalizeAngle(ramc + 180.0 + fraction * 90.0)
        }

        for _ in 0..<50 {
            // Convert RA to ecliptic longitude (point on ecliptic)
            let raRad = ra * deg2rad
            let lonRad = atan2(sin(raRad), cos(raRad) * cos(epsRad))
            let lon = normalizeAngle(lonRad * rad2deg)

            // Declination of this ecliptic longitude
            let dec = asin(sin(epsRad) * sin(lon * deg2rad))

            // Diurnal semi-arc
            let tanProd = tan(latRad) * tan(dec)
            let dsa: Double
            if abs(tanProd) >= 1.0 {
                dsa = tanProd > 0 ? 180.0 : 0.0
            } else {
                dsa = acos(-tanProd) * rad2deg
            }

            let nsa = 180.0 - dsa

            // Required RA for this cusp
            let requiredRA: Double
            if aboveHorizon {
                requiredRA = normalizeAngle(ramc + fraction * dsa)
            } else {
                requiredRA = normalizeAngle(ramc + 180.0 + fraction * nsa)
            }

            // Check convergence
            var diff = requiredRA - ra
            if diff > 180 { diff -= 360 }
            if diff < -180 { diff += 360 }

            ra = normalizeAngle(requiredRA)

            if abs(diff) < 0.0001 {
                break
            }
        }

        // Convert final RA to ecliptic longitude
        let raRad = ra * deg2rad
        let lonRad = atan2(sin(raRad), cos(raRad) * cos(epsRad))
        return normalizeAngle(lonRad * rad2deg)
    }
}

// MARK: - Public Interface

struct EphemerisResult {
    let positions: [CelestialPosition]
    let ascendant: Double
    let midheaven: Double
    let houseCusps: [Double]  // 12 Placidus house cusps (index 0 = House 1)
}

nonisolated enum Ephemeris {
    static func calculate(date: Date, latitude: Double, longitude: Double) -> EphemerisResult {
        let jd = JulianDate.fromDate(date)
        return calculate(jd: jd, latitude: latitude, longitude: longitude)
    }

    static func calculate(jd: Double, latitude: Double, longitude: Double) -> EphemerisResult {
        var positions: [CelestialPosition] = []

        // Sun
        let (sunLon, _) = SunCalculator.position(jd: jd)
        positions.append(CelestialPosition(body: .sun, longitude: sunLon, latitude: 0, isRetrograde: false))

        // Moon
        let moonLon = MoonCalculator.longitude(jd: jd)
        positions.append(CelestialPosition(body: .moon, longitude: moonLon, latitude: 0, isRetrograde: false))

        // Planets
        let planets: [CelestialBody] = [.mercury, .venus, .mars, .jupiter, .saturn, .uranus, .neptune, .pluto]
        for planet in planets {
            let lon = PlanetCalculator.geocentricLongitude(body: planet, jd: jd)
            let retro = PlanetCalculator.isRetrograde(body: planet, jd: jd)
            positions.append(CelestialPosition(body: planet, longitude: lon, latitude: 0, isRetrograde: retro))
        }

        // North Node
        let nnLon = NorthNodeCalculator.longitude(jd: jd)
        positions.append(CelestialPosition(body: .northNode, longitude: nnLon, latitude: 0, isRetrograde: true))

        // Angles
        let angles = AnglesCalculator.calculate(jd: jd, latitude: latitude, longitude: longitude)

        // Placidus house cusps
        let T = JulianDate.centuriesFromJ2000(jd)
        let eps = meanObliquity(T: T)
        let nut = nutation(T: T)
        let trueObliquity = eps + nut.obliquity
        let lst = localSiderealTime(jd: jd, longitude: longitude)

        let cusps = PlacidusCalculator.houseCusps(
            ascendant: angles.ascendant, midheaven: angles.midheaven,
            obliquity: trueObliquity, latitude: latitude, ramc: lst
        )

        return EphemerisResult(positions: positions, ascendant: angles.ascendant, midheaven: angles.midheaven, houseCusps: cusps)
    }

    static func currentPositions() -> [CelestialPosition] {
        let jd = JulianDate.fromDate(Date())
        var positions: [CelestialPosition] = []

        let (sunLon, _) = SunCalculator.position(jd: jd)
        positions.append(CelestialPosition(body: .sun, longitude: sunLon, latitude: 0, isRetrograde: false))

        let moonLon = MoonCalculator.longitude(jd: jd)
        positions.append(CelestialPosition(body: .moon, longitude: moonLon, latitude: 0, isRetrograde: false))

        let planets: [CelestialBody] = [.mercury, .venus, .mars, .jupiter, .saturn, .uranus, .neptune, .pluto]
        for planet in planets {
            let lon = PlanetCalculator.geocentricLongitude(body: planet, jd: jd)
            let retro = PlanetCalculator.isRetrograde(body: planet, jd: jd)
            positions.append(CelestialPosition(body: planet, longitude: lon, latitude: 0, isRetrograde: retro))
        }

        let nnLon = NorthNodeCalculator.longitude(jd: jd)
        positions.append(CelestialPosition(body: .northNode, longitude: nnLon, latitude: 0, isRetrograde: true))

        return positions
    }
}
