#if canImport(Darwin)
    internal import Darwin
#elseif canImport(Glibc)
    internal import Glibc
#elseif canImport(Musl)
    internal import Musl
#endif

extension ISO_9945.Kernel.User {

    public enum Real {}
}

extension ISO_9945.Kernel.User.Real {

    public static func id() -> ISO_9945.Kernel.User.ID {
        ISO_9945.Kernel.User.ID(_unchecked: getuid())
    }

    public static func set(
        _ uid: ISO_9945.Kernel.User.ID
    ) throws(Error.Error) {
        guard setuid(uid.underlying) == 0 else {
            throw Error.Error.current(operation: "setuid")
        }
    }
}
