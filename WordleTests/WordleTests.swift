import ComposableArchitecture
import XCTest

@testable import Wordle

class WordleTests: XCTestCase {
  let scheduler = DispatchQueue.test

  func testInputRules() throws {
    let store = TestStore(
      initialState: AppState(wordToGuess: "house"),
      reducer: appReducer,
      environment: AppEnvironment(
        mainQueue: scheduler.eraseToAnyScheduler()
      )
    )

    // If we send an uppercase letter, the lowercase letter gets stored
    store.send(.enterLetter("A")) { $0.input.append("a") }

    // Can't submit the guess until you've entered 5 letters
    store.send(.submitGuess)

    // Sending anything but a letter shouldn't store anything
    store.send(.enterLetter("1"))
    store.send(.enterLetter("."))
    store.send(.enterLetter(";"))
    store.send(.enterLetter(" "))

    store.send(.enterLetter("b")) { $0.input.append("b") }
    store.send(.enterLetter("c")) { $0.input.append("c") }
    store.send(.enterLetter("d")) { $0.input.append("d") }
    store.send(.enterLetter("e")) { $0.input.append("e") }

    // Can't enter more than 5 letters
    store.send(.enterLetter("f"))

    // Can't enter invalid words
    store.send(.submitGuess)
  }

  func testGame() throws {
    // Word to guess: "house".
    let store = TestStore(
      initialState: AppState(wordToGuess: "house"),
      reducer: appReducer,
      environment: AppEnvironment(
        mainQueue: scheduler.eraseToAnyScheduler()
      )
    )

    // We're going to enter the word "homer".
    store.send(.enterLetter("h")) { $0.input.append("h") }
    store.send(.enterLetter("o")) { $0.input.append("o") }
    store.send(.enterLetter("m")) { $0.input.append("m") }
    store.send(.enterLetter("e")) { $0.input.append("e") }
    store.send(.enterLetter("r")) { $0.input.append("r") }

    // We submit the guess, and expect the "h" and "o" to be correct,
    // while the "e" does exist in the word but is in the wrong position.
    store.send(.submitGuess) {
      $0.previousGuesses.append("homer")
      $0.input = []

      $0.keyboard["h"] = .correct
      $0.keyboard["o"] = .correct
      $0.keyboard["m"] = .absent
      $0.keyboard["e"] = .present
      $0.keyboard["r"] = .absent
    }

    // We're going to enter the word "hopes".
    store.send(.enterLetter("h")) { $0.input.append("h") }
    store.send(.enterLetter("o")) { $0.input.append("o") }
    store.send(.enterLetter("p")) { $0.input.append("p") }
    store.send(.enterLetter("e")) { $0.input.append("e") }
    store.send(.enterLetter("s")) { $0.input.append("s") }

    store.send(.submitGuess) {
      $0.previousGuesses.append("hopes")
      $0.input = []

      $0.keyboard["p"] = .absent
      $0.keyboard["s"] = .present
    }

    // We're going to enter the word "horse".
    store.send(.enterLetter("h")) { $0.input.append("h") }
    store.send(.enterLetter("o")) { $0.input.append("o") }
    store.send(.enterLetter("r")) { $0.input.append("r") }
    store.send(.enterLetter("s")) { $0.input.append("s") }
    store.send(.enterLetter("e")) { $0.input.append("e") }

    store.send(.submitGuess) {
      $0.previousGuesses.append("horse")
      $0.input = []

      $0.keyboard["e"] = .correct
      $0.keyboard["s"] = .correct
    }

    // We're going to enter the word "house".
    store.send(.enterLetter("h")) { $0.input.append("h") }
    store.send(.enterLetter("o")) { $0.input.append("o") }
    store.send(.enterLetter("u")) { $0.input.append("u") }
    store.send(.enterLetter("s")) { $0.input.append("s") }
    store.send(.enterLetter("e")) { $0.input.append("e") }

    store.send(.submitGuess) {
      $0.previousGuesses.append("house")
      $0.input = []
      $0.gameState = .won

      $0.keyboard["u"] = .correct
    }

    // Now that we've won the game, we can't input anything anymore
    store.send(.enterLetter("h"))

    // Reset the game
    store.send(.reset("crane")) { $0 = AppState(wordToGuess: "crane") }
  }
}
