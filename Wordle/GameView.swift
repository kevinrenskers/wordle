import ComposableArchitecture
import SwiftUI

let keyboardRows: [[Character]] = [
  ["q", "w", "e", "r", "t", "y", "u", "i", "o", "p"],
  ["a", "s", "d", "f", "g", "h", "j", "k", "l"],
  ["z", "x", "c", "v", "b", "n", "m"],
]

extension KeyboardState {
  var backgroundColor: Color {
    switch self {
      case .absent:
        return .init(hex: "3a3b3c")
      case .present:
        return .init(hex: "b59f3b")
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

struct KeyboardCharacterKey: View {
  let character: Character
  let viewStore: ViewStore<AppState, AppAction>

  @FocusState private var focused: Bool?

  var body: some View {
    Button(String(character)) {
      viewStore.send(.enterLetter(character))
    }
    .buttonStyle(KeyboardButtonStyle(
      focused: focused ?? false,
      backgroundColor: viewStore.state.keyboard[character]!?.backgroundColor ?? .init(hex: "818384"),
      width: 70)
    )
    .focused($focused, equals: true)
  }
}

struct KeyboardActionKey: View {
  let label: String
  let action: AppAction
  let viewStore: ViewStore<AppState, AppAction>

  @FocusState private var focused: Bool?

  var body: some View {
    Button(label) {
      viewStore.send(action)
    }
    .buttonStyle(KeyboardButtonStyle(
      focused: focused ?? false,
      backgroundColor: Color(hex: "818384"),
      width: 150))
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

struct AppView: View {
  let store: Store<AppState, AppAction>

  var body: some View {
    WithViewStore(self.store) { viewStore in
      VStack {
        ForEach(viewStore.previousGuesses) { guess in
          HStack(spacing: 10) {
            ForEach(Array(guess)) { character in
              Letter(letter: character)
            }
          }
        }

        HStack(spacing: 10) {
          ForEach(viewStore.input) { character in
            Letter(letter: character)
          }
          ForEach(Array(String(repeating: " ", count: 5 - viewStore.input.count))) { character in
            Letter(letter: character)
          }
        }

        VStack(spacing: 10) {
          HStack(spacing: 10) {
            ForEach(keyboardRows[0]) { character in
              KeyboardCharacterKey(character: character, viewStore: viewStore)
                .id(UUID())
            }
          }

          HStack(spacing: 10) {
            ForEach(keyboardRows[1]) { character in
              KeyboardCharacterKey(character: character, viewStore: viewStore)
                .id(UUID())
            }
          }

          HStack(spacing: 10) {
            KeyboardActionKey(label: "enter", action: .submitGuess, viewStore: viewStore)
            ForEach(keyboardRows[2]) { character in
              KeyboardCharacterKey(character: character, viewStore: viewStore)
                .id(UUID())
            }
            KeyboardActionKey(label: "backspace", action: .backspace, viewStore: viewStore)
          }
        }
      }
    }
  }
}

struct AppView_Previews: PreviewProvider {
  static var previews: some View {
    AppView(
      store: Store(
        initialState: AppState(
          wordToGuess: "house",
          previousGuesses: ["homer", "hopes"],
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
