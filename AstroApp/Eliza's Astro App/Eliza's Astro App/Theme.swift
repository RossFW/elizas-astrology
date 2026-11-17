import SwiftUI

// MARK: - Vintage Celestial Theme
// Inspired by classic "Signs of the Zodiac" astronomical poster:
// deep navy sky, warm gold accents, cream text

enum AstroTheme {
    // Primary backgrounds — lightened for readability
    static let navy = Color(red: 0.13, green: 0.15, blue: 0.26)
    static let deepNavy = Color(red: 0.09, green: 0.10, blue: 0.20)

    // Accent colors
    static let gold = Color(red: 0.90, green: 0.75, blue: 0.35)
    static let warmGold = Color(red: 0.95, green: 0.82, blue: 0.45)
    static let copper = Color(red: 0.80, green: 0.50, blue: 0.30)

    // Text colors
    static let cream = Color.white
    static let dimCream = Color(red: 0.85, green: 0.82, blue: 0.76)

    // Surface colors (cards, sections) — lightened
    static let cardBackground = Color(red: 0.17, green: 0.19, blue: 0.32)
    static let cardBorder = Color(red: 0.30, green: 0.32, blue: 0.45)

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
