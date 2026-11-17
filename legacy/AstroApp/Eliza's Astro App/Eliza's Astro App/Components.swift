import SwiftUI

// MARK: - Big Three Display

struct BigThreeView: View {
    let chart: NatalChart

    var body: some View {
        HStack(spacing: 12) {
            signPill(label: "Sun", sign: chart.sunSign)
            signPill(label: "Moon", sign: chart.moonSign)
            signPill(label: "Rising", sign: chart.risingSign)
        }
    }

    private func signPill(label: String, sign: ZodiacSign) -> some View {
        VStack(spacing: 6) {
            Image(sign.imageName)
                .resizable()
                .scaledToFit()
                .frame(width: 48, height: 48)
            Text(sign.name)
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundStyle(AstroTheme.cream)
            Text(label)
                .font(.caption2)
                .foregroundStyle(AstroTheme.dimCream)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background(AstroTheme.elementColor(sign.element).opacity(0.15))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(AstroTheme.elementColor(sign.element).opacity(0.3), lineWidth: 0.5)
        )
    }
}

// MARK: - Transit Card

struct TransitCard: View {
    let transit: Transit

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(transit.transitingPosition.body.symbol)
                    .font(.title2)
                    .foregroundStyle(AstroTheme.gold)
                Text(transit.aspectType.symbol)
                    .font(.title3)
                    .foregroundStyle(AstroTheme.dimCream)
                Text(transit.natalPosition.body.symbol)
                    .font(.title2)
                    .foregroundStyle(AstroTheme.gold)

                Spacer()

                if transit.aspectType.isHarmonious {
                    Image(systemName: "sparkle")
                        .foregroundStyle(AstroTheme.harmonious)
                } else {
                    Image(systemName: "bolt.fill")
                        .foregroundStyle(AstroTheme.challenging)
                }
            }

            Text("\(transit.transitingPosition.body.name) \(transit.aspectType.name) your \(transit.natalPosition.body.name)")
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(AstroTheme.cream)

            Text(TransitInterpretations.interpret(transit))
                .font(.caption)
                .foregroundStyle(AstroTheme.dimCream)
                .lineLimit(4)
        }
        .astroCard()
    }
}

// MARK: - Retrograde Badge

struct RetrogradeBadge: View {
    let info: RetrogradeInfo

    var body: some View {
        HStack(spacing: 6) {
            Text(info.body.symbol)
                .font(.caption)
            Text("Rx")
                .font(.caption2)
                .fontWeight(.bold)
                .foregroundStyle(AstroTheme.challenging)
            Text(info.sign.symbol)
                .font(.caption)
        }
        .foregroundStyle(AstroTheme.cream)
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(AstroTheme.challenging.opacity(0.15))
        .clipShape(Capsule())
    }
}

// MARK: - Planet Row

struct PlanetRow: View {
    let position: CelestialPosition
    let house: Int?

    var body: some View {
        HStack {
            Image(position.sign.imageName)
                .resizable()
                .scaledToFit()
                .frame(width: 32, height: 32)

            VStack(alignment: .leading, spacing: 2) {
                Text(position.body.name)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundStyle(AstroTheme.cream)
                Text(position.formattedDegree)
                    .font(.caption)
                    .foregroundStyle(AstroTheme.dimCream)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 2) {
                Text("\(position.sign.symbol) \(position.sign.name)")
                    .font(.subheadline)
                    .foregroundStyle(AstroTheme.gold)
                if let house = house {
                    Text("House \(house)")
                        .font(.caption2)
                        .foregroundStyle(AstroTheme.dimCream)
                }
            }

            if position.isRetrograde {
                Text("Rx")
                    .font(.caption2)
                    .fontWeight(.bold)
                    .foregroundStyle(AstroTheme.challenging)
                    .padding(.horizontal, 4)
                    .padding(.vertical, 2)
                    .background(AstroTheme.challenging.opacity(0.15))
                    .clipShape(Capsule())
            }
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Aspect Row

struct AspectRow: View {
    let aspect: ChartAspect

    var body: some View {
        HStack {
            Text(aspect.body1.symbol)
                .font(.title3)
                .foregroundStyle(AstroTheme.gold)
            Text(aspect.type.symbol)
                .font(.caption)
                .foregroundStyle(aspect.type.isHarmonious ? AstroTheme.harmonious : AstroTheme.challenging)
            Text(aspect.body2.symbol)
                .font(.title3)
                .foregroundStyle(AstroTheme.gold)

            Spacer()

            VStack(alignment: .trailing) {
                Text(aspect.type.name)
                    .font(.caption)
                    .foregroundStyle(AstroTheme.cream)
                Text(String(format: "%.1f\u{00B0} orb", aspect.orb))
                    .font(.caption2)
                    .foregroundStyle(AstroTheme.dimCream)
            }
        }
    }
}

// MARK: - Section Header

struct SectionHeader: View {
    let title: String
    let icon: String

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .foregroundStyle(AstroTheme.gold)
            Text(title)
                .fontWeight(.semibold)
                .foregroundStyle(AstroTheme.cream)
        }
        .font(.headline)
    }
}

// MARK: - Harmony Gauge

struct HarmonyGauge: View {
    let value: Double

    var color: Color {
        switch value {
        case 70...: AstroTheme.harmonious
        case 40..<70: AstroTheme.warmGold
        default: AstroTheme.challenging
        }
    }

    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .stroke(AstroTheme.cardBorder, lineWidth: 10)
                Circle()
                    .trim(from: 0, to: value / 100)
                    .stroke(color, style: StrokeStyle(lineWidth: 10, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                VStack {
                    Text("\(Int(value))")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundStyle(AstroTheme.cream)
                    Text("harmony")
                        .font(.caption2)
                        .foregroundStyle(AstroTheme.dimCream)
                }
            }
            .frame(width: 100, height: 100)
        }
    }
}
