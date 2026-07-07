import Foundation

struct Game: Identifiable, Hashable {
    let id: String
    let displayName: String
    let rulesURL: URL?
}
