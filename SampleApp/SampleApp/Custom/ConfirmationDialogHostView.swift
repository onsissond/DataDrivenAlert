//
//  ConfirmationDialogHostView.swift
//  SampleApp
//
//  Created by Sukhanov Evgeny on 10.01.2022.
//

import SwiftUI
import SwiftUIAlertState

struct ConfirmationDialogHostView: View {
    @State var confirmationDialogState: ConfirmationDialogState<AlertAction>?
    
    var body: some View {
        Button("Show confirmation dialog") {
            confirmationDialogState = .init(
                title: "Like out app?",
                titleVisibility: .visible,
                message: "Would you like to rate our app?\nThanks for using our app.",
                buttons: [
                    .destructive("Like", action: .send(.like)),
                    .default("Not now", action: .send(.notNow)),
                    .cancel("Cancel", action: .send(.cancel))
                ]
            )
        }
        .confirmationDialog(
            $confirmationDialogState,
            send: { action in print(action) },
            dismiss: .dismiss
        )
    }
}

struct ConfirmationDialogHostView_Previews: PreviewProvider {
    static var previews: some View {
        ConfirmationDialogHostView()
    }
}
