//
//  ContentView.swift
//  SampleApp
//
//  Created by Sukhanov Evgeny on 10.01.2022.
//

import SwiftUI
import SwiftUIAlertState

enum AlertAction {
    case ok
    case cancel
    case dismiss
}

struct ContentView: View {
    @State var alertState: AlertState<AlertAction>?
    
    var body: some View {
        Group {
            Button("Show alert") {
                alertState = .init(
                    title: TextState("Test"),
                    message: nil,
                    buttons: [
                        .destructive(TextState("Stop"), action: .send(.cancel)),
                        .default(TextState("OK"), action: .send(.ok))
                    ]
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

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
