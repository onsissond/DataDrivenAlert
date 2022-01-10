//
//  ContentView.swift
//  SampleApp
//
//  Created by Sukhanov Evgeny on 10.01.2022.
//

import SwiftUI
import SwiftUIAlertState

struct SwiftUIAlertView: View {
    @State var alertState: AlertState<AlertAction>?
    
    var body: some View {
        Button("Show alert") {
            alertState = .init(
                title: "Hello world!",
                message: nil,
                buttons: [
                    .cancel("Cancel", action: .send(.cancel)),
                    .default("OK", action: .send(.ok))
                ]
            )
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
        SwiftUIAlertView()
    }
}
