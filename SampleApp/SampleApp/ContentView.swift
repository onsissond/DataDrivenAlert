//
//  ContentView.swift
//  SampleApp
//
//  Created by Sukhanov Evgeny on 10.01.2022.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationView {
            List {
                NavigationLink("AlertHostView") {
                    AlertHostView()
                }
                NavigationLink("ConfirmationDialogHostView") {
                    ConfirmationDialogHostView()
                }
                NavigationLink("ComposableAlertHostView") {
                    ComposableAlertHostView(store: .init(
                        initialState: .init(),
                        reducer: appReducer,
                        environment: Void()
                    ))
                }
                NavigationLink("ComposableConfirmationDialogHostView") {
                    ComposableConfirmationDialogHostView(store: .init(
                        initialState: .init(),
                        reducer: appReducer,
                        environment: Void()
                    ))
                }
            }
        }
    }
}

struct ContentView_Preview: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

