#if canImport(Darwin)
    internal import Darwin
#elseif canImport(Glibc)
    internal import Glibc
#elseif canImport(Musl)
    internal import Musl
#endif

extension ISO_9945.Kernel.Socket.Pair {

    public enum Error: Swift.Error, Sendable, Equatable {

        case platform(Platform)
    }

    static func currentError() -> ISO_9945.Kernel.Socket.Pair.Error {
        .platform(.posix(errno))
    }
}

extension ISO_9945.Kernel.Socket.Pair.Error {

    public enum Platform: Sendable, Equatable {

        case posix(Int32)
    }
}

extension ISO_9945.Kernel.Socket.Pair.Error: CustomStringConvertible {
    public var description: Swift.String {
        switch self {
        case .platform(let p):
            switch p {
            case .posix(let code):
                return "socketpair failed: errno \(code)"
            }
        }
    }
}
