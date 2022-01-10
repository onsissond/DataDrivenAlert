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
                NavigationLink("SwiftUIAlert") {
                    SwiftUIAlertView()
                }
                NavigationLink("ComposableAlert") {
                    ComposableAlertView(store: .init(
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

