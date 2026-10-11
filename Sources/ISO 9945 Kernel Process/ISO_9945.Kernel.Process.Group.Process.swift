#if canImport(Darwin)
    internal import Darwin
#elseif canImport(Glibc)
    internal import Glibc
#elseif canImport(Musl)
    internal import Musl
#endif

extension ISO_9945.Kernel.Process.Group {

    public enum Process: Sendable, Equatable {

        case current

        case id(ISO_9945.Kernel.Process.ID)
    }
}
