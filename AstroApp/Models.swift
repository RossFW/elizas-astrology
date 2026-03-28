import Foundation
import SwiftUI

// MARK: - Element & Modality

enum Element: String, CaseIterable, Codable {
    case fire, earth, air, water

    var color: Color {
        switch self {
        case .fire: .red
        case .earth: .green
        case .air: .yellow
        case .water: .blue
        }
    }
}

enum Modality: String, CaseIterable, Codable {
    case cardinal, fixed, mutable
}

// MARK: - Zodiac Signs

enum ZodiacSign: Int, CaseIterable, Codable, Identifiable {
    case aries = 0, taurus, gemini, cancer, leo, virgo
    case libra, scorpio, sagittarius, capricorn, aquarius, pisces

    var id: Int { rawValue }

    var name: String {
        switch self {
        case .aries: "Aries"
        case .taurus: "Taurus"
        case .gemini: "Gemini"
        case .cancer: "Cancer"
        case .leo: "Leo"
        case .virgo: "Virgo"
        case .libra: "Libra"
        case .scorpio: "Scorpio"
        case .sagittarius: "Sagittarius"
        case .capricorn: "Capricorn"
        case .aquarius: "Aquarius"
        case .pisces: "Pisces"
        }
    }

    var symbol: String {
        switch self {
        case .aries: "\u{2648}"
        case .taurus: "\u{2649}"
        case .gemini: "\u{264A}"
        case .cancer: "\u{264B}"
        case .leo: "\u{264C}"
        case .virgo: "\u{264D}"
        case .libra: "\u{264E}"
        case .scorpio: "\u{264F}"
        case .sagittarius: "\u{2650}"
        case .capricorn: "\u{2651}"
        case .aquarius: "\u{2652}"
        case .pisces: "\u{2653}"
        }
    }

    var element: Element {
        switch self {
        case .aries, .leo, .sagittarius: .fire
        case .taurus, .virgo, .capricorn: .earth
        case .gemini, .libra, .aquarius: .air
        case .cancer, .scorpio, .pisces: .water
        }
    }

    var modality: Modality {
        switch self {
        case .aries, .cancer, .libra, .capricorn: .cardinal
        case .taurus, .leo, .scorpio, .aquarius: .fixed
        case .gemini, .virgo, .sagittarius, .pisces: .mutable
        }
    }

    var rulingBody: CelestialBody {
        switch self {
        case .aries: .mars
        case .taurus: .venus
        case .gemini: .mercury
        case .cancer: .moon
        case .leo: .sun
        case .virgo: .mercury
        case .libra: .venus
        case .scorpio: .pluto
        case .sagittarius: .jupiter
        case .capricorn: .saturn
        case .aquarius: .uranus
        case .pisces: .neptune
        }
    }

    static func from(longitude: Double) -> ZodiacSign {
        let normalized = longitude.truncatingRemainder(dividingBy: 360.0)
        let adjusted = normalized < 0 ? normalized + 360.0 : normalized
        return ZodiacSign(rawValue: Int(adjusted / 30.0) % 12) ?? .aries
    }
}

// MARK: - Celestial Bodies

enum CelestialBody: String, CaseIterable, Codable, Identifiable {
    case sun, moon, mercury, venus, mars
    case jupiter, saturn, uranus, neptune, pluto
    case northNode

    var id: String { rawValue }

    var name: String {
        switch self {
        case .northNode: "North Node"
        default: rawValue.capitalized
        }
    }

    var symbol: String {
        switch self {
        case .sun: "\u{2609}"
        case .moon: "\u{263D}"
        case .mercury: "\u{263F}"
        case .venus: "\u{2640}"
        case .mars: "\u{2642}"
        case .jupiter: "\u{2643}"
        case .saturn: "\u{2644}"
        case .uranus: "\u{2645}"
        case .neptune: "\u{2646}"
        case .pluto: "\u{2647}"
        case .northNode: "\u{260A}"
        }
    }

    var isPersonal: Bool {
        switch self {
        case .sun, .moon, .mercury, .venus, .mars: true
        default: false
        }
    }

    var isSocial: Bool {
        self == .jupiter || self == .saturn
    }

    var isOuter: Bool {
        switch self {
        case .uranus, .neptune, .pluto: true
        default: false
        }
    }
}

// MARK: - Aspects

enum AspectType: String, CaseIterable, Codable, Identifiable {
    case conjunction, sextile, square, trine, opposition

    var id: String { rawValue }

    var angle: Double {
        switch self {
        case .conjunction: 0
        case .sextile: 60
        case .square: 90
        case .trine: 120
        case .opposition: 180
        }
    }

    var orb: Double {
        switch self {
        case .conjunction: 8
        case .opposition: 8
        case .trine: 8
        case .square: 7
        case .sextile: 6
        }
    }

    var symbol: String {
        switch self {
        case .conjunction: "\u{260C}"
        case .sextile: "\u{26B9}"
        case .square: "\u{25A1}"
        case .trine: "\u{25B3}"
        case .opposition: "\u{260D}"
        }
    }

    var name: String { rawValue.capitalized }

    var isHarmonious: Bool {
        switch self {
        case .trine, .sextile: true
        case .square, .opposition: false
        case .conjunction: true
        }
    }

    var briefDescription: String {
        switch self {
        case .conjunction: "merging energy"
        case .sextile: "opportunity and flow"
        case .square: "tension and growth"
        case .trine: "harmony and ease"
        case .opposition: "balancing opposites"
        }
    }
}

// MARK: - Position & Chart Structures

struct CelestialPosition: Codable, Identifiable {
    var id: String { body.rawValue }
    let body: CelestialBody
    let longitude: Double
    let latitude: Double
    let isRetrograde: Bool

    var sign: ZodiacSign { .from(longitude: longitude) }

    var degreeInSign: Double {
        let deg = longitude.truncatingRemainder(dividingBy: 30.0)
        return deg < 0 ? deg + 30.0 : deg
    }

    var formattedDegree: String {
        let deg = Int(degreeInSign)
        let min = Int((degreeInSign - Double(deg)) * 60)
        return "\(deg)\u{00B0}\(min)' \(sign.name)"
    }

    var formattedShort: String {
        "\(body.symbol) \(sign.symbol) \(Int(degreeInSign))\u{00B0}"
    }
}

struct ChartAspect: Codable, Identifiable {
    let id: UUID
    let body1: CelestialBody
    let body2: CelestialBody
    let type: AspectType
    let orb: Double
    let isApplying: Bool

    init(body1: CelestialBody, body2: CelestialBody, type: AspectType, orb: Double, isApplying: Bool) {
        self.id = UUID()
        self.body1 = body1
        self.body2 = body2
        self.type = type
        self.orb = orb
        self.isApplying = isApplying
    }
}

struct NatalChart: Codable {
    let positions: [CelestialPosition]
    let ascendantLongitude: Double
    let midheavenLongitude: Double
    let aspects: [ChartAspect]

    var ascendantSign: ZodiacSign { .from(longitude: ascendantLongitude) }
    var midheavenSign: ZodiacSign { .from(longitude: midheavenLongitude) }

    func position(for body: CelestialBody) -> CelestialPosition? {
        positions.first { $0.body == body }
    }

    var sunSign: ZodiacSign { position(for: .sun)?.sign ?? .aries }
    var moonSign: ZodiacSign { position(for: .moon)?.sign ?? .aries }
    var risingSign: ZodiacSign { ascendantSign }

    // Whole Sign houses: house 1 = rising sign, house 2 = next sign, etc.
    func house(for longitude: Double) -> Int {
        let ascSignStart = Double(ascendantSign.rawValue) * 30.0
        var offset = longitude - ascSignStart
        if offset < 0 { offset += 360.0 }
        return (Int(offset / 30.0) % 12) + 1
    }

    func houseForBody(_ body: CelestialBody) -> Int {
        guard let pos = position(for: body) else { return 1 }
        return house(for: pos.longitude)
    }
}

// MARK: - Transits & Retrogrades

struct Transit: Identifiable {
    let id = UUID()
    let transitingPosition: CelestialPosition
    let natalPosition: CelestialPosition
    let aspectType: AspectType
    let orb: Double
    let isApplying: Bool
    let houseAffected: Int

    var significance: Int {
        var score = 0
        if transitingPosition.body.isOuter { score += 3 }
        if transitingPosition.body.isSocial { score += 2 }
        if natalPosition.body.isPersonal { score += 2 }
        if natalPosition.body == .sun || natalPosition.body == .moon { score += 1 }
        if aspectType == .conjunction || aspectType == .opposition { score += 1 }
        let orbScore = max(0, Int(5 - orb))
        score += orbScore
        return score
    }
}

struct RetrogradeInfo: Identifiable {
    let id = UUID()
    let body: CelestialBody
    let sign: ZodiacSign
    let houseInChart: Int
}
