import ComposableArchitecture

enum KeyboardState: Equatable {
  case absent
  case present
  case correct
}

enum GameState: Equatable {
  case running
  case won
  case lost
}

struct CharacterWithState: Equatable, Hashable {
  let character: Character
  let state: KeyboardState?
}

struct AppState: Equatable {
  var wordToGuess: String
  var gameState = GameState.running

  var previousGuesses: [[CharacterWithState]] = []
  var input: [Character] = []
  var keyboard: [Character: KeyboardState?] = [
    "a": nil,
    "b": nil,
    "c": nil,
    "d": nil,
    "e": nil,
    "f": nil,
    "g": nil,
    "h": nil,
    "i": nil,
    "j": nil,
    "k": nil,
    "l": nil,
    "m": nil,
    "n": nil,
    "o": nil,
    "p": nil,
    "q": nil,
    "r": nil,
    "s": nil,
    "t": nil,
    "u": nil,
    "v": nil,
    "w": nil,
    "x": nil,
    "y": nil,
    "z": nil,
  ]
}

enum AppAction: Equatable {
  case enterLetter(Character)
  case backspace
  case submitGuess
  case reset(String?)
}

struct AppEnvironment {
  var mainQueue: AnySchedulerOf<DispatchQueue>
}

let appReducer = Reducer<AppState, AppAction, AppEnvironment> { state, action, environment in
  switch action {
    case .enterLetter(let letter):
      guard state.gameState == .running, letter.isLetter, state.previousGuesses.count < 6, state.input.count < 5 else {
        return .none
      }

      state.input.append(Character(letter.lowercased()))
      return .none

    case .backspace:
      guard state.gameState == .running, state.input.count > 0 else {
        return .none
      }

      _ = state.input.popLast()

      return .none

    case .submitGuess:
      guard state.gameState == .running, state.previousGuesses.count < 6, state.input.count == 5 else {
        return .none
      }

      let guess = state.input.map(String.init).joined()
      guard guess.isValidWord else {
        return .none
      }

      // Update the overall keyboard state
      for (index, letter) in state.input.enumerated() {
        if state.wordToGuess[index] == letter {
          state.keyboard[letter] = .correct
        } else if state.wordToGuess.contains(letter) {
          if let keyboardState = state.keyboard[letter], keyboardState == nil {
            state.keyboard[letter] = .present
          }
        } else {
          state.keyboard[letter] = .absent
        }
      }

      // Determine keyboard state for this word
      let guessWithState: [CharacterWithState] = state.input.enumerated().map { index, letter in
        var letterState: KeyboardState?

        if state.wordToGuess[index] == letter {
          letterState = .correct
        } else if state.wordToGuess.contains(letter) {
          letterState = .present
        } else {
          letterState = .absent
        }

        return CharacterWithState(character: letter, state: letterState)
      }

      state.previousGuesses.append(guessWithState)

      if guess == state.wordToGuess {
        state.gameState = .won
      } else if state.previousGuesses.count == 6 {
        state.gameState = .lost
      }

      state.input = []
      return .none

    case .reset(let newWord):
      state = AppState(wordToGuess: newWord ?? words.randomElement()!)
      return .none
  }
}
