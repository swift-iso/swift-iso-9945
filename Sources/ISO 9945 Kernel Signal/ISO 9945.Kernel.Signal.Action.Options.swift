#if canImport(Darwin)
    internal import Darwin
#elseif canImport(Glibc)
    internal import Glibc
#elseif canImport(Musl)
    internal import Musl
#endif

extension ISO_9945.Kernel.Signal.Action {

    public struct Options: OptionSet, Sendable, Equatable, Hashable {
        public let rawValue: Int32

        public init(rawValue: Int32) {
            self.rawValue = rawValue
        }
    }
}

extension ISO_9945.Kernel.Signal.Action.Options {

    public static let noChildStop = Self(rawValue: Int32(truncatingIfNeeded: SA_NOCLDSTOP))

    public static let noChildWait = Self(rawValue: Int32(truncatingIfNeeded: SA_NOCLDWAIT))

    public static let resetHandler = Self(rawValue: Int32(truncatingIfNeeded: SA_RESETHAND))

    public static let restart = Self(rawValue: Int32(truncatingIfNeeded: SA_RESTART))

    public static let onStack = Self(rawValue: Int32(truncatingIfNeeded: SA_ONSTACK))

    public static let noDefer = Self(rawValue: Int32(truncatingIfNeeded: SA_NODEFER))

    public static let sigInfo = Self(rawValue: Int32(truncatingIfNeeded: SA_SIGINFO))
}
