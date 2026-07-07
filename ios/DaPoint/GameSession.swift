import Foundation
import SwiftData

enum SessionStatus: String, Codable, CaseIterable {
    case ongoing = "en_cours"
    case finished = "termine"

    var displayName: String {
        switch self {
        case .ongoing: return "En cours"
        case .finished: return "Terminée"
        }
    }
}

@Model
final class GameSession {
    var id: UUID = UUID()
    var name: String
    var gameId: String
    var startDate: Date
    var endDate: Date?
    var status: SessionStatus

    init(name: String, gameId: String, startDate: Date = Date()) {
        self.id = UUID()
        self.name = name
        self.gameId = gameId
        self.startDate = startDate
        self.status = .ongoing
    }
}
