import SwiftUI
import SwiftData

struct NewSessionView: View {
    let game: Game

    @Environment(\.modelContext) private var modelContext

    @State private var sessionName = ""
    @State private var playerNames: [String] = []
    @State private var newPlayerName = ""
    @State private var createdSession: GameSession? = nil
    @FocusState private var isPlayerFieldFocused: Bool

    private var canCreate: Bool {
        !sessionName.trimmingCharacters(in: .whitespaces).isEmpty
    }

    var body: some View {
        Form {
            Section("Partie") {
                TextField("Nom de la partie", text: $sessionName)
                    .autocorrectionDisabled()
            }

            Section {
                ForEach(playerNames, id: \.self) { name in
                    Label(name, systemImage: "person.fill")
                }
                .onDelete { playerNames.remove(atOffsets: $0) }

                HStack {
                    TextField("Ajouter un joueur", text: $newPlayerName)
                        .autocorrectionDisabled()
                        .focused($isPlayerFieldFocused)
                        .onSubmit { addPlayer() }
                    Button(action: addPlayer) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title3)
                    }
                    .buttonStyle(.plain)
                    .disabled(newPlayerName.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            } header: {
                Text("Joueurs")
            } footer: {
                if playerNames.isEmpty {
                    Text("Tu pourras aussi ajouter des joueurs depuis la page des scores.")
                }
            }
        }
        .navigationTitle("Nouvelle partie")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Créer") { create() }
                    .disabled(!canCreate)
            }
        }
        .navigationDestination(item: $createdSession) { session in
            SessionDetailView(session: session)
        }
    }

    private func addPlayer() {
        let trimmed = newPlayerName.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return }
        playerNames.append(trimmed)
        newPlayerName = ""
        isPlayerFieldFocused = true
    }

    private func create() {
        let session = GameSession(
            name: sessionName.trimmingCharacters(in: .whitespaces),
            gameId: game.id
        )
        modelContext.insert(session)

        for (index, name) in playerNames.enumerated() {
            modelContext.insert(SessionPlayer(name: name, sessionId: session.id, order: index))
        }

        createdSession = session
    }
}

#Preview {
    NavigationStack {
        NewSessionView(game: Game(id: "txek", displayName: "Txek", rulesURL: nil))
    }
    .modelContainer(for: [GameSession.self, SessionPlayer.self, RoundScore.self], inMemory: true)
}
