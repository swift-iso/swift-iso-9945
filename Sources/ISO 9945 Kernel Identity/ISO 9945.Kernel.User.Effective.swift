#if canImport(Darwin)
    internal import Darwin
#elseif canImport(Glibc)
    internal import Glibc
#elseif canImport(Musl)
    internal import Musl
#endif

extension ISO_9945.Kernel.User {

    public enum Effective {}
}

extension ISO_9945.Kernel.User.Effective {

    public static func id() -> ISO_9945.Kernel.User.ID {
        ISO_9945.Kernel.User.ID(_unchecked: geteuid())
    }

    public static func set(
        _ uid: ISO_9945.Kernel.User.ID
    ) throws(Error.Error) {
        guard seteuid(uid.underlying) == 0 else {
            throw Error.Error.current(operation: "seteuid")
        }
    }
}
