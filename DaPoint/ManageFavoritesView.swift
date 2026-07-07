import SwiftUI

struct ManageFavoritesView: View {
    @AppStorage("favoriteGameIds") private var favoriteGameIdsRaw: String = ""

    private var favoriteIds: Set<String> {
        favoriteGameIdsRaw.isEmpty
            ? Set(GamesRegistry.all.map(\.id))
            : Set(favoriteGameIdsRaw.split(separator: ",").map(String.init))
    }

    private func isFavorite(_ game: Game) -> Bool {
        favoriteIds.contains(game.id)
    }

    private func toggleFavorite(_ game: Game) {
        var ids = favoriteIds
        if ids.contains(game.id) {
            ids.remove(game.id)
        } else {
            ids.insert(game.id)
        }
        favoriteGameIdsRaw = ids.joined(separator: ",")
    }

    var body: some View {
        List(GamesRegistry.all) { game in
            Button {
                toggleFavorite(game)
            } label: {
                HStack {
                    Text(game.displayName)
                    Spacer()
                    Image(systemName: isFavorite(game) ? "star.fill" : "star")
                        .foregroundStyle(isFavorite(game) ? .yellow : .secondary)
                }
            }
            .foregroundStyle(.primary)
        }
        .navigationTitle("Gérer les favoris")
    }
}

#Preview {
    NavigationStack {
        ManageFavoritesView()
    }
}
