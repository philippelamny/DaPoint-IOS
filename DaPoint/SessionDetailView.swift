import SwiftUI
import SwiftData

struct SessionDetailView: View {
    let session: GameSession

    @Query private var players: [SessionPlayer]
    @Query private var scores: [RoundScore]
    @Environment(\.modelContext) private var modelContext

    @State private var showAddPlayer = false
    @State private var showEnterScores = false

    init(session: GameSession) {
        self.session = session
        let sid = session.id
        _players = Query(
            filter: #Predicate<SessionPlayer> { $0.sessionId == sid },
            sort: [SortDescriptor(\.order)]
        )
        _scores = Query(
            filter: #Predicate<RoundScore> { $0.sessionId == sid },
            sort: [SortDescriptor(\.roundNumber)]
        )
    }

    private var roundNumbers: [Int] {
        Array(Set(scores.map(\.roundNumber))).sorted()
    }

    private var nextRound: Int { (roundNumbers.last ?? 0) + 1 }

    private func points(for player: SessionPlayer, round: Int) -> Int? {
        scores.first(where: { $0.playerName == player.name && $0.roundNumber == round })?.points
    }

    private func total(for player: SessionPlayer) -> Int {
        scores.filter { $0.playerName == player.name }.reduce(0) { $0 + $1.points }
    }

    private func isLeader(_ player: SessionPlayer) -> Bool {
        guard !roundNumbers.isEmpty else { return false }
        let playerTotal = total(for: player)
        return playerTotal == players.map { total(for: $0) }.min()
    }

    var body: some View {
        Group {
            if players.isEmpty {
                ContentUnavailableView(
                    "Aucun joueur",
                    systemImage: "person.3",
                    description: Text("Ajoutez des joueurs pour commencer")
                )
            } else {
                ScrollView {
                    scoreTable
                        .padding()
                }
                .safeAreaInset(edge: .bottom) {
                    if session.status == .ongoing {
                        VStack(spacing: 0) {
                            Divider()
                            Button {
                                session.status = .finished
                                session.endDate = Date()
                            } label: {
                                Label("Terminer la partie", systemImage: "flag.checkered")
                                    .frame(maxWidth: .infinity)
                            }
                            .buttonStyle(.borderedProminent)
                            .tint(Color(red: 0.8, green: 0.1, blue: 0.1))
                            .padding()
                        }
                        .background(.regularMaterial)
                    }
                }
            }
        }
        .navigationTitle(session.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            if session.status == .ongoing {
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    Button { showAddPlayer = true } label: {
                        Image(systemName: "person.badge.plus")
                    }
                    if !players.isEmpty {
                        Button("Ajouter un score") { showEnterScores = true }
                    }
                }
            }
        }
        .sheet(isPresented: $showAddPlayer) {
            AddPlayerView(session: session, playerCount: players.count)
        }
        .sheet(isPresented: $showEnterScores) {
            EnterRoundScoresView(session: session, players: players, roundNumber: nextRound)
        }
    }

    private var scoreTable: some View {
        let rowH: CGFloat  = 40
        let headH: CGFloat = 34
        let nameW: CGFloat = 112
        let colW: CGFloat  = 52

        return HStack(alignment: .top, spacing: 0) {

            // ── Colonne joueurs (fixe gauche) ──────────────────────────
            VStack(alignment: .leading, spacing: 0) {
                Color.clear.frame(height: headH)
                Divider()
                ForEach(players) { player in
                    HStack(spacing: 4) {
                        if isLeader(player) {
                            Image(systemName: "crown.fill")
                                .font(.system(size: 10))
                                .foregroundStyle(.yellow)
                        }
                        Text(player.name)
                            .font(.subheadline.weight(.medium))
                            .lineLimit(1)
                    }
                    .frame(height: rowH, alignment: .leading)
                    .padding(.leading, 12)
                    Divider()
                }
            }
            .frame(width: nameW)

            Rectangle().fill(Color(.separator)).frame(width: 0.5)

            // ── Manches scrollables (plus récente en premier) ──────────
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(alignment: .top, spacing: 0) {
                    ForEach(Array(roundNumbers.reversed()), id: \.self) { round in
                        VStack(spacing: 0) {
                            Text("M\(round)")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .frame(width: colW, height: headH)
                            Divider()
                            ForEach(players) { player in
                                Text(points(for: player, round: round).map { "\($0)" } ?? "—")
                                    .font(.subheadline)
                                    .foregroundStyle(
                                        points(for: player, round: round) == nil
                                            ? Color.secondary : Color.primary
                                    )
                                    .frame(width: colW, height: rowH)
                                Divider()
                            }
                        }
                    }
                    if roundNumbers.isEmpty {
                        Color.clear.frame(width: colW)
                    }
                }
            }

            Rectangle().fill(Color(.separator)).frame(width: 0.5)

            // ── Total (fixe droite, toujours visible) ──────────────────
            VStack(spacing: 0) {
                Text("Total")
                    .font(.caption.bold())
                    .frame(width: colW + 8, height: headH)
                Divider()
                ForEach(players) { player in
                    Text("\(total(for: player))")
                        .font(.subheadline.bold())
                        .foregroundStyle(isLeader(player) ? Color.green : Color.primary)
                        .frame(width: colW + 8, height: rowH)
                    Divider()
                }
            }
        }
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

#Preview {
    let session = GameSession(name: "Partie test", gameId: "txek")
    return NavigationStack {
        SessionDetailView(session: session)
    }
    .modelContainer(for: [GameSession.self, SessionPlayer.self, RoundScore.self], inMemory: true)
}
