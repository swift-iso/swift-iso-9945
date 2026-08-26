#if canImport(Darwin)
    internal import Darwin
#elseif canImport(Glibc)
    internal import Glibc
#elseif canImport(Musl)
    internal import Musl
#endif

extension ISO_9945.Kernel.Group {

    public enum Effective {}
}

extension ISO_9945.Kernel.Group.Effective {

    public static func id() -> ISO_9945.Kernel.Group.ID {
        ISO_9945.Kernel.Group.ID(_unchecked: getegid())
    }

    public static func set(
        _ gid: ISO_9945.Kernel.Group.ID
    ) throws(Error.Error) {
        guard setegid(gid.underlying) == 0 else {
            throw Error.Error.current(operation: "setegid")
        }
    }
}
