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
        if #available(iOS 15, *) {
            state.alertState = .init(
                title: TextState("Test"),
                message: nil,
                buttons: [
                    .cancel(TextState("Stop"), action: .send(.alertAction(.cancel))),
                    .default(TextState("OK"), action: .send(.alertAction(.ok)))
                ]
            )
        } else {
            state.alertState = .init(
                title: TextState("Test"),
                message: nil,
                primaryButton:
                    .cancel(TextState("Stop"), action: .send(.alertAction(.cancel))),
                secondaryButton: .default(TextState("OK"), action: .send(.alertAction(.ok)))
            )
        }
        return .none
    case .showConfirmationDialog:
        state.confirmationDialog = .init(
            title: TextState("Like out app?"),
            message: TextState("Would you like to rate our app?\nThanks for using our app."),
            buttons: [
                .destructive(TextState("Like"), action: .send(.alertAction(.like))),
                .default(TextState("Not now"), action: .send(.alertAction(.notNow))),
                .cancel(TextState("Cancel"), action: .send(.alertAction(.cancel)))
            ]
        )
        return .none
    case .alertAction(let action):
        state.alertState = nil
        state.confirmationDialog = nil
        print(action)
        return .none
    }
}

