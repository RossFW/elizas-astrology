import SwiftUI

// MARK: - Vintage Celestial Theme
// Inspired by classic "Signs of the Zodiac" astronomical poster:
// deep navy sky, warm gold accents, cream text

enum AstroTheme {
    // Primary backgrounds
    static let navy = Color(red: 0.10, green: 0.12, blue: 0.22)
    static let deepNavy = Color(red: 0.06, green: 0.07, blue: 0.15)

    // Accent colors
    static let gold = Color(red: 0.90, green: 0.75, blue: 0.35)
    static let warmGold = Color(red: 0.95, green: 0.82, blue: 0.45)
    static let copper = Color(red: 0.80, green: 0.50, blue: 0.30)

    // Text colors
    static let cream = Color(red: 0.96, green: 0.93, blue: 0.87)
    static let dimCream = Color(red: 0.70, green: 0.67, blue: 0.60)

    // Surface colors (cards, sections)
    static let cardBackground = Color(red: 0.14, green: 0.16, blue: 0.28)
    static let cardBorder = Color(red: 0.25, green: 0.27, blue: 0.40)

    // Element colors (warmer palette matching the poster)
    static func elementColor(_ element: Element) -> Color {
        switch element {
        case .fire: Color(red: 0.90, green: 0.55, blue: 0.25)
        case .earth: Color(red: 0.55, green: 0.70, blue: 0.45)
        case .air: Color(red: 0.85, green: 0.82, blue: 0.50)
        case .water: Color(red: 0.40, green: 0.60, blue: 0.80)
        }
    }

    // Harmonious / challenging
    static let harmonious = Color(red: 0.55, green: 0.80, blue: 0.55)
    static let challenging = Color(red: 0.90, green: 0.55, blue: 0.35)
}

// MARK: - Reusable View Modifiers

struct AstroCardStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding()
            .background(AstroTheme.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(AstroTheme.cardBorder, lineWidth: 0.5)
            )
    }
}

extension View {
    func astroCard() -> some View {
        modifier(AstroCardStyle())
    }
}
