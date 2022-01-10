import SwiftUI

@available(iOS 13, *)
@available(macOS 12, *)
@available(tvOS 13, *)
@available(watchOS 6, *)
public struct ActionSheetState<Action> {
    public let id = UUID()
    public var buttons: [Button]
    public var message: TextState?
    public var title: TextState
    public var titleVisibility: Visibility
    
    @available(iOS 15, *)
    @available(macOS 12, *)
    @available(tvOS 15, *)
    @available(watchOS 8, *)
    public init(
        title: TextState,
        titleVisibility: Visibility,
        message: TextState? = nil,
        buttons: [Button] = []
    ) {
        self.buttons = buttons
        self.message = message
        self.title = title
        self.titleVisibility = titleVisibility
    }
    
    public init(
        title: TextState,
        message: TextState? = nil,
        buttons: [Button] = []
    ) {
        self.buttons = buttons
        self.message = message
        self.title = title
        self.titleVisibility = .automatic
    }
    
    public typealias Button = AlertState<Action>.Button
    
    public enum Visibility {
        case automatic
        case hidden
        case visible
        
#if compiler(>=5.5)
        @available(iOS 15, macOS 12, tvOS 15, watchOS 8, *)
        var toSwiftUI: SwiftUI.Visibility {
            switch self {
            case .automatic:
                return .automatic
            case .hidden:
                return .hidden
            case .visible:
                return .visible
            }
        }
#endif
    }
}

@available(iOS 13, *)
@available(macOS 12, *)
@available(tvOS 13, *)
@available(watchOS 6, *)
extension ActionSheetState: Equatable where Action: Equatable {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.title == rhs.title
        && lhs.message == rhs.message
        && lhs.buttons == rhs.buttons
    }
}

@available(iOS 13, *)
@available(macOS 12, *)
@available(tvOS 13, *)
@available(watchOS 6, *)
extension ActionSheetState: Hashable where Action: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.title)
        hasher.combine(self.message)
        hasher.combine(self.buttons)
    }
}

@available(iOS 13, *)
@available(macOS 12, *)
@available(tvOS 13, *)
@available(watchOS 6, *)
extension ActionSheetState: Identifiable {}

extension View {
    /// Displays a dialog when the store's state becomes non-`nil`, and dismisses it when it becomes
    /// `nil`.
    ///
    /// - Parameters:
    ///   - store: A store that describes if the dialog is shown or dismissed.
    ///   - dismissal: An action to send when the dialog is dismissed through non-user actions, such
    ///     as when a dialog is automatically dismissed by the system. Use this action to `nil` out
    ///     the associated dialog state.
    @available(iOS 13, *)
    @available(macOS 12, *)
    @available(tvOS 13, *)
    @available(watchOS 6, *)
    @ViewBuilder public func actionSheet<Action>(
        _ state: Binding<ActionSheetState<Action>?>,
        send: @escaping (Action) -> Void,
        dismiss: Action
    ) -> some View {
        if #available(iOS 15, tvOS 15, watchOS 8, *) {
            modifier(
                NewConfirmationDialogModifier(
                    state: state,
                    send: send,
                    dismiss: dismiss
                )
            )
        } else {
            modifier(
                OldConfirmationDialogModifier(
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
@available(iOS 15, macOS 12, tvOS 15, watchOS 8, *)
private struct NewConfirmationDialogModifier<Action>: ViewModifier {
    var state: Binding<ActionSheetState<Action>?>
    let send: (Action) -> Void
    let dismiss: Action
    
    func body(content: Content) -> some View {
        content.confirmationDialog(
            state.wrappedValue.map { Text($0.title) } ?? Text(""),
            isPresented: state.onChanged { send(dismiss) }.isPresent(),
            titleVisibility: state.wrappedValue?.titleVisibility.toSwiftUI ?? .automatic,
            presenting: state.wrappedValue,
            actions: { $0.toSwiftUIActions(send: send) },
            message: \.message
        )
    }
}
#endif

@available(iOS 13, *)
@available(macOS 12, *)
@available(tvOS 13, *)
@available(watchOS 6, *)
private struct OldConfirmationDialogModifier<Action>: ViewModifier {
    @Binding var state: ActionSheetState<Action>?
    let send: (Action) -> Void
    let dismiss: Action
    
    func body(content: Content) -> some View {
        content.actionSheet(item: $state.onChanged { send(dismiss) }) { state in
            state.toSwiftUIActionSheet(send: send)
        }
    }
}

@available(iOS 13, *)
@available(macOS 12, *)
@available(tvOS 13, *)
@available(watchOS 6, *)
extension ActionSheetState {
#if compiler(>=5.5)
    @available(iOS 15, macOS 12, tvOS 15, watchOS 8, *)
    @ViewBuilder
    fileprivate func toSwiftUIActions(send: @escaping (Action) -> Void) -> some View {
        ForEach(buttons.indices, id: \.self) {
            buttons[$0].toSwiftUIButton(send: send)
        }
    }
#endif
    
    @available(macOS, unavailable)
    fileprivate func toSwiftUIActionSheet(send: @escaping (Action) -> Void) -> SwiftUI.ActionSheet {
        SwiftUI.ActionSheet(
            title: Text(self.title),
            message: message.map { Text($0) },
            buttons: buttons.map {
                $0.toSwiftUIAlertButton(send: send)
            }
        )
    }
}
