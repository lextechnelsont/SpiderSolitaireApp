import SwiftUI

@main
struct SpiderSolitaireApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .windowResizability(.contentSize)
                .windowStyle(.automatic)
        }
    }
}

// MARK: - App State and ViewModel

enum AppState {
    case menu, game, settings
}

enum SuitMode: Int {
    case one = 1, two = 2, four = 4
}

class GameViewModel: ObservableObject {
    @Published var appState: AppState = .menu
    @Published var gameEngine: GameEngine = GameEngine(mode: .one)
    @Published var soundOn: Bool = true
    @Published var selectedCardStyle: CardStyle = .classic
    @Published var selectedBackground: BackgroundStyle = .greenFelt

    var gameExists: Bool {
        // TODO: Check persistent storage for saved game
        return false
    }

    func startNewGame(mode: SuitMode) {
        gameEngine = GameEngine(mode: mode)
        appState = .game
    }

    func continueGame() {
        // TODO: Load game state from persistence
        appState = .game
    }

    func undo() {
        gameEngine.undo()
    }

    func restart() {
        gameEngine.restart()
    }

    func showSettings() {
        appState = .settings
    }

    func closeSettings() {
        appState = .game
    }
}

// MARK: - Models

enum Suit: String, CaseIterable {
    case hearts, diamonds, clubs, spades
}

enum CardStyle: String, CaseIterable {
    case classic, modern
}

enum BackgroundStyle: String, CaseIterable {
    case greenFelt, woodDesk
}

struct Card: Identifiable, Equatable {
    let id = UUID()
    let suit: Suit
    let rank: Int // 1 = Ace ... 13 = King
    var isFaceUp: Bool = true
}

// MARK: - Game Engine

class GameEngine: ObservableObject {
    @Published var tableau: [[Card]] = Array(repeating: [], count: 10)
    @Published var stock: [Card] = []
    @Published var foundations: [[Card]] = Array(repeating: [], count: 8)

    private var history: [GameState] = []

    init(mode: SuitMode = .one) {
        setupNewGame(mode: mode)
    }

    private func setupNewGame(mode: SuitMode) {
        // TODO: Initialize deck with `mode.rawValue` suits, shuffle, and deal into tableau and stock
        // - Create deck
        // - Shuffle
        // - Deal 54 cards to 10 columns (first 4 columns get 6 cards, rest get 5)
        // - Rest into `stock`
        saveState()
    }

    func dealCards() {
        // TODO: Deal one card onto each tableau column from stock
        saveState()
    }

    func move(cards: [Card], fromColumn: Int, toColumn: Int) {
        // TODO: Validate that `cards` form a valid descending same-suit sequence
        // TODO: Perform move and animate in View
        saveState()
    }

    func undo() {
        // TODO: Restore last state from `history[... - 1]`
    }

    func hint() {
        // TODO: Identify a valid move and notify View to highlight
    }

    func restart() {
        // TODO: Re-run setupNewGame with current mode
    }

    private func saveState() {
        // TODO: Capture current `tableau`, `stock`, `foundations` into `history`
    }
}

struct GameState {
    var tableau: [[Card]]
    var stock: [Card]
    var foundations: [[Card]]
}

// MARK: - ContentView

struct ContentView: View {
    @StateObject private var viewModel = GameViewModel()
    @State private var showingDifficulty = false

    var body: some View {
        Group {
            switch viewModel.appState {
            case .menu:
                MainMenuView(viewModel: viewModel, showingDifficulty: $showingDifficulty)
            case .game:
                GameBoardView(viewModel: viewModel)
            case .settings:
                SettingsView(viewModel: viewModel)
            }
        }
        .sheet(isPresented: $showingDifficulty) {
            DifficultySelectionView(viewModel: viewModel, isPresented: $showingDifficulty)
        }
    }
}

// MARK: - Main Menu

struct MainMenuView: View {
    @ObservedObject var viewModel: GameViewModel
    @Binding var showingDifficulty: Bool

    var body: some View {
        VStack(spacing: 20) {
            Text("Spider Solitaire")
                .font(.largeTitle)
                .bold()

            Button("New Game") {
                showingDifficulty = true
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)

            Button("Continue Game") {
                viewModel.continueGame()
            }
            .buttonStyle(.bordered)
            .controlSize(.large)
            .disabled(!viewModel.gameExists)

            Button("Settings") {
                viewModel.showSettings()
            }
            .buttonStyle(.bordered)
            .controlSize(.large)
        }
        .padding()
    }
}

// MARK: - Difficulty Selection

struct DifficultySelectionView: View {
    @ObservedObject var viewModel: GameViewModel
    @Binding var isPresented: Bool

    var body: some View {
        VStack(spacing: 20) {
            Text("Choose Difficulty")
                .font(.title2)
                .bold()

            Button("1-Suit (Easy)") {
                viewModel.startNewGame(mode: .one)
                isPresented = false
            }
            .buttonStyle(.borderedProminent)

            Button("2-Suit (Medium)") {
                viewModel.startNewGame(mode: .two)
                isPresented = false
            }
            .buttonStyle(.borderedProminent)

            Button("4-Suit (Hard)") {
                viewModel.startNewGame(mode: .four)
                isPresented = false
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }
}

// MARK: - Settings View

struct SettingsView: View {
    @ObservedObject var viewModel: GameViewModel

    var body: some View {
        NavigationView {
            Form {
                Toggle("Sound", isOn: $viewModel.soundOn)

                Picker("Card Style", selection: $viewModel.selectedCardStyle) {
                    ForEach(CardStyle.allCases, id: \.self) { style in
                        Text(style.rawValue.capitalized)
                    }
                }

                Picker("Background", selection: $viewModel.selectedBackground) {
                    ForEach(BackgroundStyle.allCases, id: \.self) { bg in
                        Text(bg.rawValue.capitalized)
                    }
                }
            }
            .navigationTitle("Settings")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") {
                        viewModel.closeSettings()
                    }
                }
            }
        }
    }
}

// MARK: - Game Board View

struct GameBoardView: View {
    @ObservedObject var viewModel: GameViewModel

    var body: some View {
        VStack(spacing: 12) {
            TopBar(viewModel: viewModel)

            // Tableau Columns
            ScrollView(.horizontal) {
                HStack(alignment: .bottom, spacing: 8) {
                    ForEach(0..<10, id: \.self) { index in
                        TableauColumnView(cards: viewModel.gameEngine.tableau[index], columnIndex: index, viewModel: viewModel)
                    }
                }
                .padding()
            }

            // Stock and Foundations
            HStack(spacing: 20) {
                StockPileView(stock: viewModel.gameEngine.stock) {
                    viewModel.gameEngine.dealCards()
                }

                ForEach(0..<8, id: \.self) { idx in
                    FoundationPileView(cards: viewModel.gameEngine.foundations[idx])
                }
            }
            .padding()
        }
        .padding()
    }
}

// MARK: - Top Bar

struct TopBar: View {
    @ObservedObject var viewModel: GameViewModel

    var body: some View {
        HStack(spacing: 16) {
            Button("Undo") {
                viewModel.undo()
            }
            .disabled(/* TODO: viewModel.gameEngine.history.isEmpty */ false)

            Button("Hint") {
                viewModel.gameEngine.hint()
            }

            Spacer()

            Button("New Game") {
                viewModel.appState = .menu
            }

            Button("Settings") {
                viewModel.showSettings()
            }
        }
    }
}

// MARK: - Tableau Column View

struct TableauColumnView: View {
    var cards: [Card]
    let columnIndex: Int
    @ObservedObject var viewModel: GameViewModel

    var body: some View {
        VStack(spacing: -60) {
            ForEach(cards) { card in
                CardView(card: card)
                    .onTapGesture {
                        // TODO: Handle card selection and dragging via pinch gesture
                    }
            }
        }
    }
}

// MARK: - Stock Pile View

struct StockPileView: View {
    var stock: [Card]
    var dealAction: () -> Void

    var body: some View {
        Button(action: dealAction) {
            if let top = stock.last {
                CardView(card: top)
            } else {
                RoundedRectangle(cornerRadius: 4)
                    .strokeBorder()
                    .frame(width: 60, height: 90)
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Foundation Pile View

struct FoundationPileView: View {
    var cards: [Card]

    var body: some View {
        ZStack {
            if let top = cards.last {
                CardView(card: top)
            } else {
                RoundedRectangle(cornerRadius: 4)
                    .strokeBorder()
                    .frame(width: 60, height: 90)
            }
        }
    }
}

// MARK: - Card View

struct CardView: View {
    var card: Card

    var body: some View {
        ZStack {
            if card.isFaceUp {
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.white)
                    .frame(width: 60, height: 90)
                    .shadow(radius: 2)
                Text(symbol)
                    .font(.headline)
            } else {
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.gray)
                    .frame(width: 60, height: 90)
            }
        }
        // TODO: Add gaze and pinch interactions modifiers
    }

    private var symbol: String {
        let rankStr: String = {
            switch card.rank {
            case 1: return "A"
            case 11: return "J"
            case 12: return "Q"
            case 13: return "K"
            default: return "\(card.rank)"
            }
        }()
        let suitSymbol: String = {
            switch card.suit {
            case .hearts: return "♥︎"
            case .diamonds: return "♦︎"
            case .clubs: return "♣︎"
            case .spades: return "♠︎"
            }
        }()
        return "\(rankStr)\(suitSymbol)"
    }
}

// Note: This code provides the core structure and UI for a 2D Spider Solitaire game on visionOS 2.
// Game logic, persistence, and detailed gesture handling are marked with TODO placeholders for implementation.
