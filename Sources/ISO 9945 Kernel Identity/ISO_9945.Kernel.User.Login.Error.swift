#if canImport(Darwin)
    internal import Darwin
#elseif canImport(Glibc)
    internal import Glibc
#elseif canImport(Musl)
    internal import Musl
#endif

extension ISO_9945.Kernel.User.Login {

    public enum Error: Swift::Error, Sendable, Equatable {
        case lookup(Error::Error.Code)
    }
}

extension ISO_9945.Kernel.User.Login.Error: CustomStringConvertible {
    public var description: Swift::String {
        switch self {
        case .lookup(let code):
            return "login name lookup failed: \(code)"
        }
    }
}
