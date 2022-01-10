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
