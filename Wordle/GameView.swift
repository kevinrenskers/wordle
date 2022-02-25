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

  func makeBody(configuration: Self.Configuration) -> some View {
    configuration.label
      .foregroundColor(.white)
      .cornerRadius(16)
      .frame(width: 70, height: 70, alignment: .center)
      .border(focused ? .white : .clear, width: 2)
  }
}

struct KeyboardKey: View {
  let character: Character
  let viewStore: ViewStore<AppState, AppAction>

  @FocusState private var focused: Bool?

  var body: some View {
    Button(String(character)) {
      print("YO!")
      viewStore.send(.enterLetter(character))
    }
      .buttonStyle(KeyboardButtonStyle(focused: focused ?? false))
      .background(viewStore.state.keyboard[character]!?.backgroundColor ?? .init(hex: "818384"))
      .focused($focused, equals: true)
  }
}

struct AppView: View {
  let store: Store<AppState, AppAction>

  var body: some View {
    WithViewStore(self.store) { viewStore in
      VStack {
        ForEach(viewStore.previousGuesses) { guess in
          Text(guess)
        }

        HStack {
          ForEach(viewStore.input) { character in
            Text(String(character))
          }
        }

        VStack(spacing: 10) {
          ForEach(keyboardRows) { row in
            HStack(spacing: 10) {
              ForEach(row) { character in
                KeyboardKey(character: character, viewStore: viewStore)
              }
            }
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
