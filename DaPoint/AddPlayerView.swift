import SwiftUI
import SwiftData

struct AddPlayerView: View {
    let session: GameSession
    let playerCount: Int

    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var name = ""

    var body: some View {
        NavigationStack {
            Form {
                TextField("Nom du joueur", text: $name)
                    .autocorrectionDisabled()
            }
            .navigationTitle("Ajouter un joueur")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Annuler") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Ajouter") { save() }
                        .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
    }

    private func save() {
        let player = SessionPlayer(
            name: name.trimmingCharacters(in: .whitespaces),
            sessionId: session.id,
            order: playerCount
        )
        modelContext.insert(player)
        dismiss()
    }
}
