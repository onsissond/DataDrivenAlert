//
//  AppStore.swift
//  SampleApp
//
//  Created by Sukhanov Evgeny on 10.01.2022.
//

import ComposableArchitecture

struct AppState: Equatable {
    var alertState: ComposableArchitecture.AlertState<AppAction>?
    var confirmationDialog: ComposableArchitecture.ConfirmationDialogState<AppAction>?
}

enum AppAction: Equatable {
    case showAlert
    case showConfirmationDialog
    case alertAction(AlertAction)
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
    case .showConfirmationDialog:
        state.confirmationDialog = .init(
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

