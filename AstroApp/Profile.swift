import Foundation
import SwiftData

@Model
final class Profile {
    var name: String
    var birthDate: Date
    var birthLatitude: Double
    var birthLongitude: Double
    var birthLocationName: String
    var isUser: Bool
    var photoData: Data?
    var createdAt: Date

    // Birth time is encoded in birthDate — if unknown, set to noon
    var hasBirthTime: Bool

    init(
        name: String,
        birthDate: Date,
        birthLatitude: Double,
        birthLongitude: Double,
        birthLocationName: String,
        isUser: Bool = false,
        hasBirthTime: Bool = true
    ) {
        self.name = name
        self.birthDate = birthDate
        self.birthLatitude = birthLatitude
        self.birthLongitude = birthLongitude
        self.birthLocationName = birthLocationName
        self.isUser = isUser
        self.hasBirthTime = hasBirthTime
        self.createdAt = Date()
    }

    var firstName: String {
        name.components(separatedBy: " ").first ?? name
    }
}
