#if canImport(Darwin)
    internal import Darwin
#elseif canImport(Glibc)
    internal import Glibc
#elseif canImport(Musl)
    internal import Musl
#endif

extension ISO_9945.Kernel.Process.Wait {

    public struct Options: OptionSet, Sendable, Hashable {
        public let rawValue: Int32

        public init(rawValue: Int32) {
            self.rawValue = rawValue
        }
    }
}

extension ISO_9945.Kernel.Process.Wait.Options {

    public static var no: No { No() }

    public static let untraced = Self(rawValue: WUNTRACED)

    public static let continued = Self(rawValue: WCONTINUED)

    public static let exited = Self(rawValue: WEXITED)

    public static let stopped = Self(rawValue: WSTOPPED)
}
