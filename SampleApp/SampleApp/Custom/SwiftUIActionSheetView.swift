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
        Button("Show alert") {
            actionSheetState = .init(
                title: "Test",
                message: nil,
                buttons: [
                    .cancel("Stop", action: .send(.cancel)),
                    .default("OK", action: .send(.ok))
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
