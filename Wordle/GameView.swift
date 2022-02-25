import ComposableArchitecture
import SwiftUI

struct AppView: View {
  let store: Store<AppState, AppAction>

  var body: some View {
    WithViewStore(self.store) { viewStore in
      Text("Hello, world!")
        .padding()
    }
  }
}

struct AppView_Previews: PreviewProvider {
  static var previews: some View {
    AppView(
      store: Store(
        initialState: AppState(wordToGuess: "house"),
        reducer: appReducer,
        environment: AppEnvironment(
          mainQueue: .main
        )
      )
    )
  }
}
