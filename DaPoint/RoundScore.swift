import Foundation
import SwiftData

@Model
final class RoundScore {
    var sessionId: UUID
    var roundNumber: Int
    var playerName: String
    var points: Int

    init(sessionId: UUID, roundNumber: Int, playerName: String, points: Int) {
        self.sessionId = sessionId
        self.roundNumber = roundNumber
        self.playerName = playerName
        self.points = points
    }
}
