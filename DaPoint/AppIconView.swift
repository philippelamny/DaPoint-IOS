import SwiftUI

// MARK: - Palette partagée

extension Color {
    static let brandStart  = Color(red: 0.18, green: 0.26, blue: 0.83)
    static let brandEnd    = Color(red: 0.49, green: 0.14, blue: 0.83)
    static let brandAccent = Color(red: 1.00, green: 0.62, blue: 0.00)
}

extension LinearGradient {
    static let brand = LinearGradient(
        colors: [.brandStart, .brandEnd],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
}

// MARK: - Marque (utilisée dans l'icône et le splash)

struct LogoMark: View {
    var size: CGFloat = 120

    var body: some View {
        ZStack {
            Text("D")
                .font(.system(size: size * 0.68, weight: .black, design: .rounded))
                .foregroundStyle(.white)

            // Le "Point" de DaPoint
            Circle()
                .fill(Color.brandAccent)
                .frame(width: size * 0.2, height: size * 0.2)
                .shadow(color: .black.opacity(0.25), radius: size * 0.025)
                .offset(x: size * 0.265, y: size * 0.225)
        }
        .frame(width: size, height: size)
    }
}

// MARK: - Icône complète (fond + marque)

struct AppIconView: View {
    var size: CGFloat = 120

    var body: some View {
        LinearGradient.brand
            .frame(width: size, height: size)
            // Xcode clip l'icône automatiquement — le clipShape ici sert à la preview
            .clipShape(RoundedRectangle(cornerRadius: size * 0.225, style: .continuous))
            .overlay { LogoMark(size: size) }
    }
}

// MARK: - Exporteur d'icône (outil de développement)
// Lance l'app, va sur la tab "Exporter icône" depuis le debug menu,
// puis sauvegarde l'image dans Photos pour la glisser dans Xcode.

struct IconExporterView: View {
    @State private var exported = false

    var body: some View {
        VStack(spacing: 24) {
            AppIconView(size: 300)
                .shadow(radius: 20)

            Text("DaPoint")
                .font(.system(size: 28, weight: .black, design: .rounded))

            Button {
                exportIcon()
            } label: {
                Label(
                    exported ? "Sauvegardé dans Photos ✓" : "Exporter l'icône (1024×1024)",
                    systemImage: exported ? "checkmark.circle.fill" : "square.and.arrow.down"
                )
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .disabled(exported)
            .padding(.horizontal)
        }
        .navigationTitle("Icône app")
    }

    private func exportIcon() {
        let renderer = ImageRenderer(content: AppIconView(size: 1024))
        renderer.scale = 1
        guard let img = renderer.uiImage else { return }
        UIImageWriteToSavedPhotosAlbum(img, nil, nil, nil)
        exported = true
    }
}

// MARK: - Previews

#Preview("Icon 1024", traits: .fixedLayout(width: 1024, height: 1024)) {
    AppIconView(size: 1024)
}

#Preview("Icon small") {
    AppIconView(size: 120)
        .padding()
}
