import SwiftUI

public struct TextState: Equatable, Hashable {
    fileprivate var modifiers: [Modifier] = []
    fileprivate let storage: Storage
    
    fileprivate enum Modifier: Equatable, Hashable {
        case accessibilityHeading(AccessibilityHeadingLevel)
        case accessibilityLabel(TextState)
        case accessibilityTextContentType(AccessibilityTextContentType)
        case baselineOffset(CGFloat)
        case bold
        case font(Font?)
        case fontWeight(Font.Weight?)
        case foregroundColor(Color?)
        case italic
        case kerning(CGFloat)
        case strikethrough(active: Bool, color: Color?)
        case tracking(CGFloat)
        case underline(active: Bool, color: Color?)
    }
    
    fileprivate enum Storage: Equatable, Hashable {
        indirect case concatenated(TextState, TextState)
        case localized(LocalizedStringKey, tableName: String?, bundle: Bundle?, comment: StaticString?)
        case verbatim(String)
        
        static func == (lhs: Self, rhs: Self) -> Bool {
            switch (lhs, rhs) {
            case let (.concatenated(l1, l2), .concatenated(r1, r2)):
                return l1 == r1 && l2 == r2
                
            case let (.localized(lk, lt, lb, lc), .localized(rk, rt, rb, rc)):
                return lk.formatted(tableName: lt, bundle: lb, comment: lc)
                == rk.formatted(tableName: rt, bundle: rb, comment: rc)
                
            case let (.verbatim(lhs), .verbatim(rhs)):
                return lhs == rhs
                
            case let (.localized(key, tableName, bundle, comment), .verbatim(string)),
                let (.verbatim(string), .localized(key, tableName, bundle, comment)):
                return key.formatted(tableName: tableName, bundle: bundle, comment: comment) == string
                
                // NB: We do not attempt to equate concatenated cases.
            default:
                return false
            }
        }
        
        func hash(into hasher: inout Hasher) {
            enum Key {
                case concatenated
                case localized
                case verbatim
            }
            
            switch self {
            case let (.concatenated(first, second)):
                hasher.combine(Key.concatenated)
                hasher.combine(first)
                hasher.combine(second)
                
            case let .localized(key, tableName, bundle, comment):
                hasher.combine(Key.localized)
                hasher.combine(key.formatted(tableName: tableName, bundle: bundle, comment: comment))
                
            case let .verbatim(string):
                hasher.combine(Key.verbatim)
                hasher.combine(string)
            }
        }
    }
}

// MARK: - API

extension TextState {
    public init(verbatim content: String) {
        self.storage = .verbatim(content)
    }
    
    @_disfavoredOverload
    public init<S>(_ content: S) where S: StringProtocol {
        self.init(verbatim: String(content))
    }
    
    public init(
        _ key: LocalizedStringKey,
        tableName: String? = nil,
        bundle: Bundle? = nil,
        comment: StaticString? = nil
    ) {
        self.storage = .localized(key, tableName: tableName, bundle: bundle, comment: comment)
    }
    
    public static func + (lhs: Self, rhs: Self) -> Self {
        .init(storage: .concatenated(lhs, rhs))
    }
    
    public func baselineOffset(_ baselineOffset: CGFloat) -> Self {
        var `self` = self
        `self`.modifiers.append(.baselineOffset(baselineOffset))
        return `self`
    }
    
    public func bold() -> Self {
        var `self` = self
        `self`.modifiers.append(.bold)
        return `self`
    }
    
    public func font(_ font: Font?) -> Self {
        var `self` = self
        `self`.modifiers.append(.font(font))
        return `self`
    }
    
    public func fontWeight(_ weight: Font.Weight?) -> Self {
        var `self` = self
        `self`.modifiers.append(.fontWeight(weight))
        return `self`
    }
    
    public func foregroundColor(_ color: Color?) -> Self {
        var `self` = self
        `self`.modifiers.append(.foregroundColor(color))
        return `self`
    }
    
    public func italic() -> Self {
        var `self` = self
        `self`.modifiers.append(.italic)
        return `self`
    }
    
    public func kerning(_ kerning: CGFloat) -> Self {
        var `self` = self
        `self`.modifiers.append(.kerning(kerning))
        return `self`
    }
    
    public func strikethrough(_ active: Bool = true, color: Color? = nil) -> Self {
        var `self` = self
        `self`.modifiers.append(.strikethrough(active: active, color: color))
        return `self`
    }
    
    public func tracking(_ tracking: CGFloat) -> Self {
        var `self` = self
        `self`.modifiers.append(.tracking(tracking))
        return `self`
    }
    
    public func underline(_ active: Bool = true, color: Color? = nil) -> Self {
        var `self` = self
        `self`.modifiers.append(.underline(active: active, color: color))
        return `self`
    }
}

// MARK: Accessibility

extension TextState {
    public enum AccessibilityTextContentType: String, Equatable, Hashable {
        case console, fileSystem, messaging, narrative, plain, sourceCode, spreadsheet, wordProcessing
        
#if compiler(>=5.5.1)
        @available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
        var toSwiftUI: SwiftUI.AccessibilityTextContentType {
            switch self {
            case .console: return .console
            case .fileSystem: return .fileSystem
            case .messaging: return .messaging
            case .narrative: return .narrative
            case .plain: return .plain
            case .sourceCode: return .sourceCode
            case .spreadsheet: return .spreadsheet
            case .wordProcessing: return .wordProcessing
            }
        }
#endif
    }
    
    public enum AccessibilityHeadingLevel: String, Equatable, Hashable {
        case h1, h2, h3, h4, h5, h6, unspecified
        
#if compiler(>=5.5.1)
        @available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
        var toSwiftUI: SwiftUI.AccessibilityHeadingLevel {
            switch self {
            case .h1: return .h1
            case .h2: return .h2
            case .h3: return .h3
            case .h4: return .h4
            case .h5: return .h5
            case .h6: return .h6
            case .unspecified: return .unspecified
            }
        }
#endif
    }
}

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
extension TextState {
    public func accessibilityHeading(_ headingLevel: AccessibilityHeadingLevel) -> Self {
        var `self` = self
        `self`.modifiers.append(.accessibilityHeading(headingLevel))
        return `self`
    }
    
    public func accessibilityLabel(_ string: String) -> Self {
        var `self` = self
        `self`.modifiers.append(.accessibilityLabel(.init(string)))
        return `self`
    }
    
    public func accessibilityLabel<S: StringProtocol>(_ string: S) -> Self {
        var `self` = self
        `self`.modifiers.append(.accessibilityLabel(.init(string)))
        return `self`
    }
    
    public func accessibilityLabel(
        _ key: LocalizedStringKey, tableName: String? = nil, bundle: Bundle? = nil,
        comment: StaticString? = nil
    ) -> Self {
        var `self` = self
        `self`.modifiers.append(
            .accessibilityLabel(.init(key, tableName: tableName, bundle: bundle, comment: comment)))
        return `self`
    }
    
    public func accessibilityTextContentType(_ type: AccessibilityTextContentType) -> Self {
        var `self` = self
        `self`.modifiers.append(.accessibilityTextContentType(type))
        return `self`
    }
}

extension Text {
    public init(_ state: TextState) {
        let text: Text
        switch state.storage {
        case let .concatenated(first, second):
            text = Text(first) + Text(second)
        case let .localized(content, tableName, bundle, comment):
            text = .init(content, tableName: tableName, bundle: bundle, comment: comment)
        case let .verbatim(content):
            text = .init(verbatim: content)
        }
        self = state.modifiers.reduce(text) { text, modifier in
            switch modifier {
#if compiler(>=5.5.1)
            case let .accessibilityHeading(level):
                if #available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *) {
                    return text.accessibilityHeading(level.toSwiftUI)
                } else {
                    return text
                }
            case let .accessibilityLabel(value):
                if #available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *) {
                    switch value.storage {
                    case let .verbatim(string):
                        return text.accessibilityLabel(string)
                    case let .localized(key, tableName, bundle, comment):
                        return text.accessibilityLabel(
                            Text(key, tableName: tableName, bundle: bundle, comment: comment))
                    case .concatenated(_, _):
                        assertionFailure("`.accessibilityLabel` does not support contcatenated `TextState`")
                        return text
                    }
                } else {
                    return text
                }
            case let .accessibilityTextContentType(type):
                if #available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *) {
                    return text.accessibilityTextContentType(type.toSwiftUI)
                } else {
                    return text
                }
#else
            case .accessibilityHeading,
                    .accessibilityLabel,
                    .accessibilityTextContentType:
                return text
#endif
            case let .baselineOffset(baselineOffset):
                return text.baselineOffset(baselineOffset)
            case .bold:
                return text.bold()
            case let .font(font):
                return text.font(font)
            case let .fontWeight(weight):
                return text.fontWeight(weight)
            case let .foregroundColor(color):
                return text.foregroundColor(color)
            case .italic:
                return text.italic()
            case let .kerning(kerning):
                return text.kerning(kerning)
            case let .strikethrough(active, color):
                return text.strikethrough(active, color: color)
            case let .tracking(tracking):
                return text.tracking(tracking)
            case let .underline(active, color):
                return text.underline(active, color: color)
            }
        }
    }
}

extension TextState: View {
    public var body: some View {
        Text(self)
    }
}

extension String {
    public init(state: TextState, locale: Locale? = nil) {
        switch state.storage {
        case let .concatenated(lhs, rhs):
            self = String(state: lhs, locale: locale) + String(state: rhs, locale: locale)
            
        case let .localized(key, tableName, bundle, comment):
            self = key.formatted(
                locale: locale,
                tableName: tableName,
                bundle: bundle,
                comment: comment
            )
            
        case let .verbatim(string):
            self = string
        }
    }
}

extension LocalizedStringKey {
    // NB: `LocalizedStringKey` conforms to `Equatable` but returns false for equivalent format
    //     strings. To account for this we reflect on it to extract and string-format its storage.
    fileprivate func formatted(
        locale: Locale? = nil,
        tableName: String? = nil,
        bundle: Bundle? = nil,
        comment: StaticString? = nil
    ) -> String {
        let children = Array(Mirror(reflecting: self).children)
        let key = children[0].value as! String
        let arguments: [CVarArg] = Array(Mirror(reflecting: children[2].value).children)
            .compactMap {
                let children = Array(Mirror(reflecting: $0.value).children)
                let value: Any
                let formatter: Formatter?
                // `LocalizedStringKey.FormatArgument` differs depending on OS/platform.
                if children[0].label == "storage" {
                    (value, formatter) =
                    Array(Mirror(reflecting: children[0].value).children)[0].value as! (Any, Formatter?)
                } else {
                    value = children[0].value
                    formatter = children[1].value as? Formatter
                }
                return formatter?.string(for: value) ?? value as! CVarArg
            }
        
        let format = NSLocalizedString(
            key,
            tableName: tableName,
            bundle: bundle ?? .main,
            value: "",
            comment: comment.map(String.init) ?? ""
        )
        return String(format: format, locale: locale, arguments: arguments)
    }
}

extension TextState: ExpressibleByStringLiteral {
    public init(stringLiteral value: StringLiteralType) {
        self.init(value)
    }
}
