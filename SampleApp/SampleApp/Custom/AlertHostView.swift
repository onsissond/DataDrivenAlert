//
//  AlertHostView.swift
//  SampleApp
//
//  Created by Sukhanov Evgeny on 10.01.2022.
//

import SwiftUI
import SwiftUIAlertState

struct AlertHostView: View {
    @State var alertState: AlertState<AlertAction>?
    
    var body: some View {
        Button("Show alert") {
            if #available(iOS 15, *) {
                alertState = .init(
                    title: "Do you want to delete this account?",
                    message: "You cannot undo this action",
                    buttons: [
                        .cancel("Cancel", action: .send(.cancel)),
                        .destructive("Delete", action: .send(.delete))
                    ]
                )
            } else {
                alertState = .init(
                    title: "Do you want to delete this account?",
                    message: "You cannot undo this action",
                    primaryButton: .cancel("Cancel", action: .send(.cancel)),
                    secondaryButton: .destructive("Delete", action: .send(.delete))
                )
            }
        }
        .alert(
            $alertState,
            send: { action in print(action) },
            dismiss: .dismiss
        )
    }
}

struct SwiftUIAlertView_Previews: PreviewProvider {
    static var previews: some View {
        AlertHostView()
    }
}
