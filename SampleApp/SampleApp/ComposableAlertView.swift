//
//  ComposableAlertView.swift
//  SampleApp
//
//  Created by Sukhanov Evgeny on 10.01.2022.
//

import SwiftUI
import ComposableArchitecture

struct ComposableAlertView: View {
    @State var store: Store<AppState, AppAction>
    
    var body: some View {
        WithViewStore(store) { viewStore in
            Button("Show alert") {
                viewStore.send(.showAlert)
            }
            .alert(
                store.scope(state: \.alertState),
                dismiss: .alertAction(.dismiss)
            )
        }
    }
}

struct ComposableAlertView_Previews: PreviewProvider {
    static var previews: some View {
        ComposableAlertView(store: .init(
            initialState: .init(),
            reducer: .empty,
            environment: Void()
        ))
    }
}

enum AppAction: Equatable {
    case showAlert
    case alertAction(AlertAction)
}
struct AppState: Equatable {
    var alertState: ComposableArchitecture.AlertState<AppAction>?
}
let appReducer = Reducer<AppState, AppAction, Void> { state, action, _ in
    switch action {
    case .showAlert:
        state.alertState = .init(
            title: TextState("Test"),
            message: nil,
            buttons: [
                .cancel(TextState("Stop"), action: .send(.alertAction(.cancel))),
                .default(TextState("OK"), action: .send(.alertAction(.ok)))
            ]
        )
        return .none
    case .alertAction(let action):
        print(action)
        return .none
    }
}
