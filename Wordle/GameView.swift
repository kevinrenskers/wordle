import ComposableArchitecture
import SwiftUI

let keyboardRows: [[Character]] = [
  ["q", "w", "e", "r", "t", "y", "u", "i", "o", "p"],
  ["a", "s", "d", "f", "g", "h", "j", "k", "l"],
  ["z", "x", "c", "v", "b", "n", "m"],
]

extension CharacterState {
  var backgroundColor: Color {
    switch self {
      case .absent:
        return .init(hex: "3a3b3c")
      case .present:
        return .init(hex: "85c0f9")
      case .correct:
        return .init(hex: "538d4e")
    }
  }
}

struct KeyboardButtonStyle: ButtonStyle {
  let focused: Bool
  let backgroundColor: Color
  let width: CGFloat

  func makeBody(configuration: Self.Configuration) -> some View {
    configuration.label
      .foregroundColor(.white)
      .frame(width: width, height: 70, alignment: .center)
      .background(backgroundColor)
      .cornerRadius(16)
      .overlay(RoundedRectangle(cornerRadius: 16)
                .stroke(focused ? .white : .clear, lineWidth: 2))
  }
}

struct KeyboardKey: View {
  let label: String
  let backgroundColor: Color?
  let width: CGFloat
  let sendAction: AppAction
  let viewStore: ViewStore<AppState, AppAction>

  @FocusState private var focused: Bool?

  var body: some View {
    Button(label) {
      viewStore.send(sendAction)
    }
    .buttonStyle(KeyboardButtonStyle(
      focused: focused ?? false,
      backgroundColor: backgroundColor ?? .init(hex: "818384"),
      width: width)
    )
    .focused($focused, equals: true)
  }
}

struct Letter: View {
  var letter: Character

  var body: some View {
    Text(String(letter))
      .frame(width: 70, height: 70, alignment: .center)
      .border(.white, width: 2)
  }
}

struct GameDone: View {
  let gameState: GameState
  let viewStore: ViewStore<AppState, AppAction>

  var body: some View {
    VStack(spacing: 40) {
      Text(gameState == .won ? "You've won!" : "Awww. The word was \(viewStore.wordToGuess)!")

      Button("Play again") {
        viewStore.send(.reset(nil))
      }
    }
    .padding(40)
    .background(.black)
  }
}

struct AppView: View {
  let store: Store<AppState, AppAction>

  var body: some View {
    WithViewStore(self.store) { viewStore in
      VStack {
        ZStack {
          // Grid
          VStack(spacing: 10) {
            // Previous guesses
            ForEach(viewStore.previousGuesses, id: \.self) { word in
              HStack(spacing: 10) {
                ForEach(word, id: \.self) { characterWithState in
                  Letter(letter: characterWithState.character)
                    .background(characterWithState.state.backgroundColor)
                }
              }
            }

            // Current input
            if viewStore.gameState == .running {
              HStack(spacing: 10) {
                ForEach(Array(viewStore.input.enumerated()), id: \.offset) { _, character in
                  Letter(letter: character)
                }
                ForEach(Array(Array(repeating: " ", count: 5 - viewStore.input.count).enumerated()), id: \.offset) { index, character in
                  Letter(letter: Character(index == 0 ? "_" : character))
                }
              }
            }

            // Fill with empty rows until we have 6 rows in total
            if viewStore.previousGuesses.count < 6 {
              ForEach((0 ..< (viewStore.gameState == .running ? 5 : 6) - viewStore.previousGuesses.count).map { $0 }, id: \.self) { _ in
                HStack(spacing: 10) {
                  ForEach(Array(Array(repeating: " ", count: 5).enumerated()), id: \.offset) { _, character in
                    Letter(letter: Character(character))
                  }
                }
              }
            }
          }

          if viewStore.gameState != .running {
            GameDone(gameState: viewStore.gameState, viewStore: viewStore)
          }
        }

        Spacer()

        // Keyboard
        VStack(spacing: 10) {
          HStack(spacing: 10) {
            ForEach(keyboardRows[0], id: \.self) { character in
              KeyboardKey(
                label: String(character),
                backgroundColor: viewStore.state.keyboard[character]!?.backgroundColor,
                width: 70,
                sendAction: .enterLetter(character),
                viewStore: viewStore
              )
            }
          }

          HStack(spacing: 10) {
            ForEach(keyboardRows[1], id: \.self) { character in
              KeyboardKey(
                label: String(character),
                backgroundColor: viewStore.state.keyboard[character]!?.backgroundColor,
                width: 70,
                sendAction: .enterLetter(character),
                viewStore: viewStore
              )
            }
          }

          HStack(spacing: 10) {
            KeyboardKey(
              label: "enter",
              backgroundColor: nil,
              width: 150,
              sendAction: .submitGuess,
              viewStore: viewStore
            )

            ForEach(keyboardRows[2], id: \.self) { character in
              KeyboardKey(
                label: String(character),
                backgroundColor: viewStore.state.keyboard[character]!?.backgroundColor,
                width: 70,
                sendAction: .enterLetter(character),
                viewStore: viewStore
              )
            }

            KeyboardKey(
              label: "backspace",
              backgroundColor: nil,
              width: 150,
              sendAction: .backspace,
              viewStore: viewStore
            )
          }
        }
      }
      .padding(.vertical, 40)
    }
  }
}

struct AppView_Previews: PreviewProvider {
  static var previews: some View {
    AppView(
      store: Store(
        initialState: AppState(
          wordToGuess: "house",
          previousGuesses: [
            [
              .init(character: "h", state: .correct),
              .init(character: "o", state: .correct),
              .init(character: "m", state: .absent),
              .init(character: "e", state: .present),
              .init(character: "r", state: .absent)
            ],
            [
              .init(character: "h", state: .correct),
              .init(character: "o", state: .correct),
              .init(character: "r", state: .absent),
              .init(character: "s", state: .correct),
              .init(character: "e", state: .correct)
            ]
          ],
          input: ["h", "o"],
          keyboard: [
            "a": nil,
            "b": nil,
            "c": nil,
            "d": nil,
            "e": .present,
            "f": nil,
            "g": nil,
            "h": .correct,
            "i": nil,
            "j": nil,
            "k": nil,
            "l": nil,
            "m": nil,
            "n": nil,
            "o": .correct,
            "p": .absent,
            "q": nil,
            "r": .absent,
            "s": .present,
            "t": nil,
            "u": nil,
            "v": nil,
            "w": nil,
            "x": nil,
            "y": nil,
            "z": nil,
          ]
        ),
        reducer: appReducer,
        environment: AppEnvironment(
          mainQueue: .main
        )
      )
    )
  }
}
