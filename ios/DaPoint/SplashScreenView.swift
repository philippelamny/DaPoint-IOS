import SwiftUI
import SwiftData

struct SplashScreenView: View {
    @State private var phase: SplashPhase = .hidden

    var body: some View {
        switch phase {
        case .hidden, .visible:
            splashContent
        case .done:
            HomeView()
        }
    }

    // MARK: - Splash content

    private var splashContent: some View {
        ZStack {
            LinearGradient.brand
                .ignoresSafeArea()

            VStack(spacing: 20) {
                LogoMark(size: 140)
                    .scaleEffect(phase == .hidden ? 0.55 : 1.0)
                    .opacity(phase == .hidden ? 0 : 1)

                VStack(spacing: 6) {
                    Text("DaPoint")
                        .font(.system(size: 38, weight: .black, design: .rounded))
                        .foregroundStyle(.white)

                    Text("Suivi de jeux")
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(.white.opacity(0.7))
                        .kerning(1.5)
                }
                .opacity(phase == .hidden ? 0 : 1)
                .offset(y: phase == .hidden ? 12 : 0)
            }
        }
        .task { await runAnimation() }
    }

    // MARK: - Animation sequence

    private func runAnimation() async {
        withAnimation(.spring(duration: 0.65, bounce: 0.35)) {
            phase = .visible
        }
        try? await Task.sleep(for: .seconds(1.6))
        withAnimation(.easeInOut(duration: 0.35)) {
            phase = .done
        }
    }
}

private enum SplashPhase {
    case hidden, visible, done
}

#Preview {
    SplashScreenView()
        .modelContainer(for: [GameSession.self, SessionPlayer.self, RoundScore.self], inMemory: true)
}
