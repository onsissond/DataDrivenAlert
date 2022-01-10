//
//  SwiftUIActionSheetView.swift
//  SampleApp
//
//  Created by Sukhanov Evgeny on 10.01.2022.
//

import SwiftUI
import SwiftUIAlertState

struct SwiftUIActionSheetView: View {
    @State var actionSheetState: ActionSheetState<AlertAction>?
    
    var body: some View {
        Button("Show action sheet") {
            actionSheetState = .init(
                title: "Hello world!",
                message: nil,
                buttons: [
                    .default("OK", action: .send(.ok)),
                    .default("I am not sure", action: .send(.possible)),
                    .destructive("No no no", action: .send(.no)),
                    .cancel("Cancel", action: .send(.cancel))
                ]
            )
        }
        .actionSheet(
            $actionSheetState,
            send: { action in print(action) },
            dismiss: .dismiss
        )
    }
}

struct SwiftUIActionSheetView_Previews: PreviewProvider {
    static var previews: some View {
        SwiftUIActionSheetView()
    }
}
