import ComposableArchitecture
import SwiftUI

@main
struct WordleApp: App {
    var body: some Scene {
        WindowGroup {
          AppView(
              store: Store(
                initialState: AppState(wordToGuess: "house"), // words.randomElement()!
                reducer: appReducer,
                environment: AppEnvironment(
                  mainQueue: .main
                )
              )
            )
        }
    }
}
