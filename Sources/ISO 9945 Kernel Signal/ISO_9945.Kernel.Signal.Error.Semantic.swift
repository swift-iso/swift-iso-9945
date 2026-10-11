#if canImport(Darwin)
    internal import Darwin
#elseif canImport(Glibc)
    internal import Glibc
#elseif canImport(Musl)
    internal import Musl
#endif

extension ISO_9945.Kernel.Signal.Error {

    public enum Semantic: Sendable {

        case invalidSignal

        case noPermission

        case noSuchProcess

        case interrupted
    }
}
