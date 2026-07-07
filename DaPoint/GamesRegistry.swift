import Foundation

enum GamesRegistry {
    static let all: [Game] = [
        Game(id: "txek", displayName: "Txek", rulesURL: URL(string: "https://www.txek.fr/txek-faq/"))
    ]

    static func game(for id: String) -> Game? {
        all.first { $0.id == id }
    }
}
