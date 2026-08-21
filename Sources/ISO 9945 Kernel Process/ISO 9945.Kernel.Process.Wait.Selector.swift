#if canImport(Darwin)
    internal import Darwin
#elseif canImport(Glibc)
    internal import Glibc
#elseif canImport(Musl)
    internal import Musl
#endif

extension ISO_9945.Kernel.Process.Wait {

    public enum Selector: Sendable, Equatable {

        case any

        case process(ISO_9945.Kernel.Process.ID)

        case group(ISO_9945.Kernel.Process.Group.ID)

        case current
    }
}
