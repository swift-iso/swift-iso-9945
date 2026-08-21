#if canImport(Darwin)
    internal import Darwin
#elseif canImport(Glibc)
    internal import Glibc
#elseif canImport(Musl)
    internal import Musl
#endif

extension ISO_9945.Kernel.Process {

    public enum Session {}
}

extension ISO_9945.Kernel.Process.Session {

    public typealias ID = Tagged<ISO_9945.Kernel.Process.Session, Int32>
}

extension ISO_9945.Kernel.Process.Session {

    public static func create() throws(ISO_9945.Kernel.Process.Error) -> ID {
        let result = setsid()
        guard result != -1 else {
            throw .session(Error_Primitives.Error.captureErrno())
        }
        return ID(_unchecked: result)
    }

    public static func id(
        of pid: ISO_9945.Kernel.Process.ID
    ) throws(ISO_9945.Kernel.Process.Error) -> ID {
        let result = getsid(pid.rawValue)
        guard result != -1 else {
            throw .session(Error_Primitives.Error.captureErrno())
        }
        return ID(_unchecked: result)
    }
}
