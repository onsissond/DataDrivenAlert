import SwiftUI

public struct AlertState<Action> {
    public let id = UUID()
    public var buttons: [Button]
    public var message: TextState?
    public var title: TextState
    
    @available(iOS 15, macOS 12, tvOS 15, watchOS 8, *)
    public init(
        title: TextState,
        message: TextState? = nil,
        buttons: [Button]
    ) {
        self.title = title
        self.message = message
        self.buttons = buttons
    }
    
    public init(
        title: TextState,
        message: TextState? = nil,
        dismissButton: Button? = nil
    ) {
        self.title = title
        self.message = message
        self.buttons = dismissButton.map { [$0] } ?? []
    }
    
    public init(
        title: TextState,
        message: TextState? = nil,
        primaryButton: Button,
        secondaryButton: Button
    ) {
        self.title = title
        self.message = message
        self.buttons = [primaryButton, secondaryButton]
    }
    
    public struct Button {
        public var action: ButtonAction?
        public var label: TextState
        public var role: ButtonRole?
        
        public static func cancel(
            _ label: TextState,
            action: ButtonAction? = nil
        ) -> Self {
            Self(action: action, label: label, role: .cancel)
        }
        
        public static func `default`(
            _ label: TextState,
            action: ButtonAction? = nil
        ) -> Self {
            Self(action: action, label: label, role: nil)
        }
        
        public static func destructive(
            _ label: TextState,
            action: ButtonAction? = nil
        ) -> Self {
            Self(action: action, label: label, role: .destructive)
        }
    }
    
    public struct ButtonAction {
        public let type: ActionType
        
        public static func send(_ action: Action) -> Self {
            .init(type: .send(action))
        }
        
        public static func send(_ action: Action, animation: Animation?) -> Self {
            .init(type: .animatedSend(action, animation: animation))
        }
        
        public enum ActionType {
            case send(Action)
            case animatedSend(Action, animation: Animation?)
        }
    }
    
    public enum ButtonRole {
        case cancel
        case destructive
        
#if compiler(>=5.5)
        @available(iOS 15, macOS 12, tvOS 15, watchOS 8, *)
        var toSwiftUI: SwiftUI.ButtonRole {
            switch self {
            case .cancel:
                return .cancel
            case .destructive:
                return .destructive
            }
        }
#endif
    }
}

extension View {
    /// Displays an alert when then store's state becomes non-`nil`, and dismisses it when it becomes
    /// `nil`.
    ///
    /// - Parameters:
    ///   - store: A store that describes if the alert is shown or dismissed.
    ///   - dismissal: An action to send when the alert is dismissed through non-user actions, such
    ///     as when an alert is automatically dismissed by the system. Use this action to `nil` out
    ///     the associated alert state.
    @ViewBuilder
    public func alert<Action>(
        _ state: Binding<AlertState<Action>?>,
        send: @escaping (Action) -> Void,
        dismiss: Action
    ) -> some View {
        if #available(iOS 15, macOS 12, tvOS 15, watchOS 8, *) {
            self.modifier(
                NewAlertModifier(
                    state: state,
                    send: send,
                    dismiss: dismiss
                )
            )
        } else {
            self.modifier(
                OldAlertModifier(
                    state: state,
                    send: send,
                    dismiss: dismiss
                )
            )
        }
    }
}

#if compiler(>=5.5)
// NB: Workaround for iOS 14 runtime crashes during iOS 15 availability checks.
//@available(iOS 15, macOS 12, tvOS 15, watchOS 8, *)
@available(iOS 15, macOS 12, tvOS 15, watchOS 8, *)
private struct NewAlertModifier<Action>: ViewModifier {
    var state: Binding<AlertState<Action>?>
    let send: (Action) -> Void
    let dismiss: Action
    
    func body(content: Content) -> some View {
        content.alert(
            state.wrappedValue.map { Text($0.title) } ?? Text(""),
            isPresented: state.onChanged { send(dismiss) }.isPresent(),
            presenting: state.wrappedValue,
            actions: { $0.toSwiftUIActions(send: send) },
            message: { $0.message.map { SwiftUI.Text($0) } }
        )
    }
}
#endif

private struct OldAlertModifier<Action>: ViewModifier {
    @Binding var state: AlertState<Action>?
    let send: (Action) -> Void
    let dismiss: Action
    
    func body(content: Content) -> some View {
        content.alert(item: $state.onChanged { send(dismiss) }) { state in
            state.toSwiftUIAlert(send: send)
        }
    }
}

extension AlertState: Equatable where Action: Equatable {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.title == rhs.title
        && lhs.message == rhs.message
        && lhs.buttons == rhs.buttons
    }
}

extension AlertState: Hashable where Action: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.title)
        hasher.combine(self.message)
        hasher.combine(self.buttons)
    }
}

extension AlertState: Identifiable {}

extension AlertState.ButtonAction: Equatable where Action: Equatable {}
extension AlertState.ButtonAction.ActionType: Equatable where Action: Equatable {}
extension AlertState.ButtonRole: Equatable {}
extension AlertState.Button: Equatable where Action: Equatable {}

extension AlertState.ButtonAction: Hashable where Action: Hashable {}
extension AlertState.ButtonAction.ActionType: Hashable where Action: Hashable {
    public func hash(into hasher: inout Hasher) {
        switch self {
        case let .send(action), let .animatedSend(action, animation: _):
            hasher.combine(action)
        }
    }
}
extension AlertState.ButtonRole: Hashable {}
extension AlertState.Button: Hashable where Action: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.action)
        hasher.combine(self.label)
        hasher.combine(self.role)
    }
}

extension AlertState.Button {
    func toSwiftUIAction(send: @escaping (Action) -> Void) -> () -> Void {
        return {
            switch self.action?.type {
            case .none:
                return
            case let .some(.send(action)):
                send(action)
            case let .some(.animatedSend(action, animation: animation)):
                withAnimation(animation) { send(action) }
            }
        }
    }
    
    func toSwiftUIAlertButton(send: @escaping (Action) -> Void) -> SwiftUI.Alert.Button {
        let action = self.toSwiftUIAction(send: send)
        switch self.role {
        case .cancel:
            return .cancel(Text(label), action: action)
        case .destructive:
            return .destructive(Text(label), action: action)
        case .none:
            return .default(Text(label), action: action)
        }
    }
    
#if compiler(>=5.5)
    @available(iOS 15, macOS 12, tvOS 15, watchOS 8, *)
    func toSwiftUIButton(send: @escaping (Action) -> Void) -> some View {
        SwiftUI.Button(
            role: self.role?.toSwiftUI,
            action: self.toSwiftUIAction(send: send)
        ) {
            Text(self.label)
        }
    }
#endif
}

extension AlertState {
#if compiler(>=5.5)
    @available(iOS 15, macOS 12, tvOS 15, watchOS 8, *)
    @ViewBuilder
    fileprivate func toSwiftUIActions(send: @escaping (Action) -> Void) -> some View {
        ForEach(self.buttons.indices, id: \.self) {
            self.buttons[$0].toSwiftUIButton(send: send)
        }
    }
#endif
    
    fileprivate func toSwiftUIAlert(send: @escaping (Action) -> Void) -> SwiftUI.Alert {
        if self.buttons.count == 2 {
            return SwiftUI.Alert(
                title: Text(self.title),
                message: self.message.map { Text($0) },
                primaryButton: self.buttons[0].toSwiftUIAlertButton(send: send),
                secondaryButton: self.buttons[1].toSwiftUIAlertButton(send: send)
            )
        } else {
            return SwiftUI.Alert(
                title: Text(self.title),
                message: self.message.map { Text($0) },
                dismissButton: self.buttons.first?.toSwiftUIAlertButton(send: send)
            )
        }
    }
}

extension Binding {
    func onChanged(_ action: @escaping () -> Void) -> Binding<Value> {
        .init(
            get: { wrappedValue },
            set: { value, transaction in
                self.transaction(transaction).wrappedValue = value
                action()
            }
        )
    }
}
