import SwiftUI
import SwiftData

struct EnterRoundScoresView: View {
    let session: GameSession
    let players: [SessionPlayer]
    let roundNumber: Int

    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var entries: [String: String] = [:]

    private var allValid: Bool {
        players.allSatisfy { player in
            guard let val = entries[player.name], !val.isEmpty else { return false }
            return Int(val) != nil
        }
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Manche \(roundNumber) — Points par joueur") {
                    ForEach(players) { player in
                        HStack {
                            Text(player.name)
                            Spacer()
                            TextField("0", text: Binding(
                                get: { entries[player.name] ?? "" },
                                set: { entries[player.name] = $0.filter(\.isNumber) }
                            ))
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 80)
                        }
                    }
                }
            }
            .scrollDismissesKeyboard(.interactively)
            .navigationTitle("Saisir les scores")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Annuler") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Valider") { save() }
                        .disabled(!allValid)
                }
            }
        }
    }

    private func save() {
        for player in players {
            let points = Int(entries[player.name] ?? "0") ?? 0
            let entry = RoundScore(
                sessionId: session.id,
                roundNumber: roundNumber,
                playerName: player.name,
                points: points
            )
            modelContext.insert(entry)
        }
        dismiss()
    }
}
