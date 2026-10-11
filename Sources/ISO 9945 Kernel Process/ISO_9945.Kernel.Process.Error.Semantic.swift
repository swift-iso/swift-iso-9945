#if canImport(Darwin)
    import Darwin
#elseif canImport(Glibc)
    import Glibc
#elseif canImport(Musl)
    import Musl
#endif

extension ISO_9945.Kernel.Process.Error {

    public enum Semantic: Sendable {

        case resourceLimit

        case noPermission

        case noSuchProcess

        case interrupted

        case invalidArgument
    }
}
