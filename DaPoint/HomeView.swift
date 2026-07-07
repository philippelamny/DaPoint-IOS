import SwiftUI
import SwiftData

struct HomeView: View {
    @AppStorage("favoriteGameIds") private var favoriteGameIdsRaw: String = ""
    @State private var showManageFavorites = false

    private var favoriteGames: [Game] {
        guard !favoriteGameIdsRaw.isEmpty else { return GamesRegistry.all }
        let ids = favoriteGameIdsRaw.split(separator: ",").map(String.init)
        return ids.compactMap { GamesRegistry.game(for: $0) }
    }

    var body: some View {
        NavigationStack {
            List(favoriteGames) { game in
                NavigationLink(value: game) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(game.displayName)
                            .font(.headline)
                        Text("Suivi des parties")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.vertical, 4)
                }
            }
            .navigationTitle("Suivi de jeux")
            .navigationDestination(for: Game.self) { game in
                SessionListView(game: game)
            }
            .navigationDestination(isPresented: $showManageFavorites) {
                ManageFavoritesView()
            }
            .toolbar {
                if GamesRegistry.all.count > 1 {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button {
                            showManageFavorites = true
                        } label: {
                            Label("Gérer les favoris", systemImage: "star.circle")
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    HomeView()
        .modelContainer(for: GameSession.self, inMemory: true)
}
