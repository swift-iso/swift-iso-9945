#if canImport(Darwin)
    internal import Darwin
#elseif canImport(Glibc)
    internal import Glibc
#elseif canImport(Musl)
    internal import Musl
#endif

extension ISO_9945.Kernel.Group {

    public enum Real {}
}

extension ISO_9945.Kernel.Group.Real {

    public static func id() -> ISO_9945.Kernel.Group.ID {
        ISO_9945.Kernel.Group.ID(_unchecked: getgid())
    }

    public static func set(
        _ gid: ISO_9945.Kernel.Group.ID
    ) throws(Error.Error) {
        guard setgid(gid.underlying) == 0 else {
            throw Error.Error.current(operation: "setgid")
        }
    }
}
