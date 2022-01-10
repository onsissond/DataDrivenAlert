//
//  File.swift
//  
//
//  Created by Sukhanov Evgeny on 10.01.2022.
//

import SwiftUI

extension Binding {
    func isPresent<Wrapped>() -> Binding<Bool> where Value == Wrapped? {
        .init(
            get: { self.wrappedValue != nil },
            set: { isPresent, transaction in
                guard !isPresent else { return }
                self.transaction(transaction).wrappedValue = nil
            }
        )
    }
}
