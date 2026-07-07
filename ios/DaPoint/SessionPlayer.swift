import Foundation
import SwiftData

@Model
final class SessionPlayer {
    var name: String
    var sessionId: UUID
    var order: Int

    init(name: String, sessionId: UUID, order: Int) {
        self.name = name
        self.sessionId = sessionId
        self.order = order
    }
}
