#if canImport(Darwin)
    internal import Darwin
#elseif canImport(Glibc)
    internal import Glibc
#elseif canImport(Musl)
    internal import Musl
#endif

extension ISO_9945.Kernel.Environment {

    public enum Error: Swift.Error, Sendable {
        case permission(ISO_9945.Kernel.Permission.Error)
        case invalid(Invalid)
        case platform(Error::Error)
    }
}

extension ISO_9945.Kernel.Environment.Error: Equatable {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        switch (lhs, rhs) {
        case (.permission(let l), .permission(let r)): return l == r
        case (.invalid(let l), .invalid(let r)): return l == r
        case (.platform(let l), .platform(let r)): return l == r
        default: return false
        }
    }
}

extension ISO_9945.Kernel.Environment.Error: CustomStringConvertible {
    public var description: Swift.String {
        switch self {
        case .permission(let e): return "permission: \(e)"
        case .invalid(let e): return "invalid: \(e)"
        case .platform(let e): return "\(e)"
        }
    }
}

extension ISO_9945.Kernel.Environment.Error {
    internal init(code: Error::Error.Code) {
        if let e = ISO_9945.Kernel.Permission.Error(code: code) {
            self = .permission(e)
            return
        }

        self = .platform(Error::Error(code: code))
    }

    internal static func current() -> Self {
        Self(code: .captureErrno())
    }
}
