import SwiftUI

@main
struct LoundryCodeApp: App {
    var body: some Scene {
        WindowGroup {
            HomeView()
        }
    }
}

struct HomeView: View {
    @State private var idea = ""
    @State private var showingEnvironment = false

    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    colors: [.purple.opacity(0.24), .blue.opacity(0.16), .cyan.opacity(0.12)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: 22) {
                        HStack {
                            LoundyMascot()
                            VStack(alignment: .leading, spacing: 3) {
                                Text("loundrycode")
                                    .font(.system(size: 30, weight: .black, design: .rounded))
                                Text("turn messy ideas into real projects")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                            Spacer()
                            Button {
                                showingEnvironment = true
                            } label: {
                                Image(systemName: "terminal.fill")
                                    .font(.title3.weight(.bold))
                                    .padding(12)
                                    .background(.thinMaterial, in: Circle())
                            }
                        }

                        VStack(alignment: .leading, spacing: 10) {
                            Text("what are we building?")
                                .font(.title2.bold())

                            TextEditor(text: $idea)
                                .frame(minHeight: 170)
                                .scrollContentBackground(.hidden)
                                .padding(12)
                                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 24))
                                .overlay {
                                    RoundedRectangle(cornerRadius: 24)
                                        .strokeBorder(
                                            LinearGradient(colors: [.purple, .blue, .cyan], startPoint: .leading, endPoint: .trailing),
                                            lineWidth: 1.5
                                        )
                                }

                            HStack {
                                Label("no credits", systemImage: "infinity")
                                Spacer()
                                Text("\(idea.count) chars")
                                    .foregroundStyle(.secondary)
                            }
                            .font(.caption.weight(.semibold))
                        }

                        Button {
                        } label: {
                            HStack {
                                Image(systemName: "sparkles")
                                Text("build my idea")
                                Spacer()
                                Image(systemName: "arrow.right")
                            }
                            .font(.headline.weight(.bold))
                            .padding()
                            .foregroundStyle(.white)
                            .background(
                                LinearGradient(colors: [.purple, .blue, .cyan], startPoint: .leading, endPoint: .trailing),
                                in: RoundedRectangle(cornerRadius: 20)
                            )
                        }
                        .disabled(idea.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                        .opacity(idea.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? 0.5 : 1)

                        VStack(alignment: .leading, spacing: 12) {
                            Text("v0.3")
                                .font(.headline)
                            Text("the app shell is here. the next layers connect the planner, model hub, environments, and real project execution.")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        .padding()
                        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 20))
                    }
                    .padding(20)
                }
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $showingEnvironment) {
                EnvironmentView()
            }
        }
    }
}

struct LoundyMascot: View {
    @State private var spinning = false

    var body: some View {
        ZStack {
            Circle()
                .fill(
                    AngularGradient(
                        colors: [.purple, .blue, .cyan, .pink, .purple],
                        center: .center
                    )
                )
            RoundedRectangle(cornerRadius: 10)
                .fill(.black.opacity(0.78))
                .frame(width: 30, height: 22)
                .overlay {
                    HStack(spacing: 7) {
                        Circle().fill(.white).frame(width: 4, height: 4)
                        Circle().fill(.white).frame(width: 4, height: 4)
                    }
                }
                .rotationEffect(.degrees(spinning ? 360 : 0))
        }
        .frame(width: 58, height: 58)
        .shadow(color: .purple.opacity(0.35), radius: 12)
        .onAppear {
            withAnimation(.linear(duration: 2.8).repeatForever(autoreverses: false)) {
                spinning = true
            }
        }
        .accessibilityLabel("loundy mascot")
    }
}

struct EnvironmentView: View {
    var body: some View {
        NavigationStack {
            List {
                Section("ai's environment") {
                    Label("linux / bash", systemImage: "terminal")
                    Label("windows / powershell", systemImage: "pc")
                    Label("macos / zsh", systemImage: "apple.logo")
                }
                Section("activity") {
                    Label("planner ready", systemImage: "brain")
                    Label("environment ready", systemImage: "hammer")
                    Label("build + test pipeline ready", systemImage: "checkmark.seal")
                }
            }
            .navigationTitle("ai's environment")
        }
    }
}
