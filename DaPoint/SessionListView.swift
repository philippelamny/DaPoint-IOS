import SwiftUI
import SwiftData

struct SessionListView: View {
    let game: Game

    @Query private var sessions: [GameSession]

    @Environment(\.modelContext) private var modelContext
    @State private var showResetAlert = false
    @State private var filterExpanded = false
    @State private var filterName = ""
    @State private var filterStatus: SessionStatus? = .ongoing
    @State private var filterStartDateEnabled = false
    @State private var filterStartDate = Date()
    @State private var filterEndDateEnabled = false
    @State private var filterEndDate = Date()

    init(game: Game) {
        self.game = game
        let gameId = game.id
        _sessions = Query(
            filter: #Predicate<GameSession> { $0.gameId == gameId },
            sort: [SortDescriptor(\.startDate, order: .reverse)]
        )
    }

    private var filteredSessions: [GameSession] {
        sessions.filter { session in
            if let status = filterStatus, session.status != status { return false }
            if !filterName.isEmpty, !session.name.localizedCaseInsensitiveContains(filterName) { return false }
            if filterStartDateEnabled, session.startDate < filterStartDate { return false }
            if filterEndDateEnabled {
                guard let end = session.endDate, end <= filterEndDate else { return false }
            }
            return true
        }
    }

    private var isFiltering: Bool {
        filterStatus != nil || !filterName.isEmpty || filterStartDateEnabled || filterEndDateEnabled
    }

    var body: some View {
        List {
            Section {
                NavigationLink(destination: NewSessionView(game: game)) {
                    Label("Nouvelle partie", systemImage: "plus.circle.fill")
                        .font(.headline)
                        .foregroundStyle(Color.accentColor)
                }
            }

            DisclosureGroup(isExpanded: $filterExpanded) {
                filterSection
            } label: {
                Label(
                    "Filtres",
                    systemImage: isFiltering
                        ? "line.3.horizontal.decrease.circle.fill"
                        : "line.3.horizontal.decrease.circle"
                )
                .foregroundStyle(isFiltering ? Color.accentColor : Color.secondary)
            }

            ForEach(filteredSessions) { session in
                NavigationLink(value: session) {
                    SessionRowView(session: session)
                }
            }
        }
        .navigationTitle(game.displayName)
        .navigationDestination(for: GameSession.self) { session in
            SessionDetailView(session: session)
        }
        .toolbar {
            if let url = game.rulesURL {
                ToolbarItem(placement: .navigationBarLeading) {
                    Link(destination: url) {
                        Label("Règles", systemImage: "book.pages")
                    }
                }
            }
            if !sessions.isEmpty {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(role: .destructive) {
                        showResetAlert = true
                    } label: {
                        Image(systemName: "trash")
                    }
                }
            }
        }
        .alert("Réinitialiser la liste ?", isPresented: $showResetAlert) {
            Button("Supprimer toutes les parties", role: .destructive) {
                resetAllSessions()
            }
            Button("Annuler", role: .cancel) {}
        } message: {
            Text("Toutes les parties et leurs scores seront supprimés définitivement.")
        }
    }

    private func resetAllSessions() {
        for session in sessions {
            let sid = session.id
            try? modelContext.delete(model: SessionPlayer.self,
                where: #Predicate<SessionPlayer> { $0.sessionId == sid })
            try? modelContext.delete(model: RoundScore.self,
                where: #Predicate<RoundScore> { $0.sessionId == sid })
            modelContext.delete(session)
        }
    }

    @ViewBuilder
    private var filterSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            TextField("Nom", text: $filterName)
                .textFieldStyle(.roundedBorder)

            Picker("Statut", selection: $filterStatus) {
                Text("Tous").tag(Optional<SessionStatus>.none)
                ForEach(SessionStatus.allCases, id: \.self) { status in
                    Text(status.displayName).tag(Optional(status))
                }
            }
            .pickerStyle(.segmented)

            Toggle("Date de début après le", isOn: $filterStartDateEnabled)
            if filterStartDateEnabled {
                DatePicker("", selection: $filterStartDate, displayedComponents: .date)
                    .datePickerStyle(.compact)
                    .labelsHidden()
            }

            Toggle("Date de fin avant le", isOn: $filterEndDateEnabled)
            if filterEndDateEnabled {
                DatePicker("", selection: $filterEndDate, displayedComponents: .date)
                    .datePickerStyle(.compact)
                    .labelsHidden()
            }
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Row

struct SessionRowView: View {
    let session: GameSession

    @Query private var players: [SessionPlayer]
    @Query private var scores: [RoundScore]
    @State private var showDetail = false

    init(session: GameSession) {
        self.session = session
        let sid = session.id
        _players = Query(
            filter: #Predicate<SessionPlayer> { $0.sessionId == sid },
            sort: [SortDescriptor(\.order)]
        )
        _scores = Query(
            filter: #Predicate<RoundScore> { $0.sessionId == sid }
        )
    }

    private func total(for player: SessionPlayer) -> Int {
        scores.filter { $0.playerName == player.name }.reduce(0) { $0 + $1.points }
    }

    private var bestPlayer: SessionPlayer? {
        guard !players.isEmpty, !scores.isEmpty else { return nil }
        return players.min(by: { total(for: $0) < total(for: $1) })
    }

    var body: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 4) {
                Text(session.name)
                    .font(.headline)

                HStack(spacing: 8) {
                    Text(session.startDate, style: .date)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    if !players.isEmpty {
                        Label("\(players.count)", systemImage: "person.2.fill")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }

                if let best = bestPlayer {
                    HStack(spacing: 4) {
                        Image(systemName: "crown.fill")
                            .font(.caption2)
                            .foregroundStyle(.yellow)
                        Text(best.name)
                            .font(.caption)
                        Text("· \(total(for: best)) pts")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 8) {
                StatusBadge(status: session.status)

                if !players.isEmpty {
                    Button {
                        showDetail = true
                    } label: {
                        Image(systemName: "info.circle")
                            .foregroundStyle(.secondary)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .padding(.vertical, 4)
        .sheet(isPresented: $showDetail) {
            SessionScoreSummarySheet(session: session, players: players, scores: scores)
        }
    }
}

// MARK: - Detail sheet

struct SessionScoreSummarySheet: View {
    let session: GameSession
    let players: [SessionPlayer]
    let scores: [RoundScore]

    @Environment(\.dismiss) private var dismiss

    private func total(for player: SessionPlayer) -> Int {
        scores.filter { $0.playerName == player.name }.reduce(0) { $0 + $1.points }
    }

    private var sortedPlayers: [SessionPlayer] {
        players.sorted { total(for: $0) < total(for: $1) }
    }

    var body: some View {
        NavigationStack {
            List {
                ForEach(sortedPlayers.indices, id: \.self) { index in
                    let player = sortedPlayers[index]
                    let playerTotal = total(for: player)
                    let isLeader = index == 0 && !scores.isEmpty
                    HStack {
                        Group {
                            if isLeader {
                                Image(systemName: "crown.fill")
                                    .foregroundStyle(.yellow)
                            } else {
                                Text("\(index + 1).")
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .frame(width: 28, alignment: .center)

                        Text(player.name)

                        Spacer()

                        Text("\(playerTotal) pts")
                            .fontWeight(isLeader ? .bold : .regular)
                            .foregroundStyle(isLeader ? Color.green : Color.primary)
                    }
                }
            }
            .navigationTitle(session.name)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Fermer") { dismiss() }
                }
            }
        }
    }
}

// MARK: - Status badge

private struct StatusBadge: View {
    let status: SessionStatus

    var body: some View {
        Text(status.displayName)
            .font(.caption)
            .padding(.horizontal, 8)
            .padding(.vertical, 2)
            .background(status == .ongoing ? Color.green.opacity(0.15) : Color.secondary.opacity(0.15))
            .foregroundStyle(status == .ongoing ? Color.green : Color.secondary)
            .clipShape(Capsule())
    }
}

#Preview {
    NavigationStack {
        SessionListView(game: Game(id: "txek", displayName: "Txek", rulesURL: nil))
    }
    .modelContainer(for: [GameSession.self, SessionPlayer.self, RoundScore.self], inMemory: true)
}
