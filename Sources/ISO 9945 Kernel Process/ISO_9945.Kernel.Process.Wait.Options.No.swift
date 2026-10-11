#if canImport(Darwin)
    internal import Darwin
#elseif canImport(Glibc)
    internal import Glibc
#elseif canImport(Musl)
    internal import Musl
#endif

extension ISO_9945.Kernel.Process.Wait.Options {

    public struct No: Sendable {

        public init() {}
    }
}

extension ISO_9945.Kernel.Process.Wait.Options.No {

    public var hang: ISO_9945.Kernel.Process.Wait.Options {
        ISO_9945.Kernel.Process.Wait.Options(rawValue: WNOHANG)
    }

    public var wait: ISO_9945.Kernel.Process.Wait.Options {
        ISO_9945.Kernel.Process.Wait.Options(rawValue: WNOWAIT)
    }
}
