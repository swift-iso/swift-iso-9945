#if canImport(Darwin)
    internal import Darwin
#elseif canImport(Glibc)
    internal import Glibc
#elseif canImport(Musl)
    internal import Musl
#endif

extension ISO_9945.Kernel.Signal {

    public enum Send {}
}

extension ISO_9945.Kernel.Signal.Send {

    public static func toProcess(
        _ signal: ISO_9945.Kernel.Signal.Number,
        pid: ISO_9945.Kernel.Process.ID
    ) throws(ISO_9945.Kernel.Signal.Error) {
        guard kill(pid.rawValue, signal.rawValue) == 0 else {
            throw .send(Error_Primitives.Error.captureErrno())
        }
    }

    public static func toSelf(
        _ signal: ISO_9945.Kernel.Signal.Number
    ) throws(ISO_9945.Kernel.Signal.Error) {
        guard raise(signal.rawValue) == 0 else {
            throw .send(Error_Primitives.Error.captureErrno())
        }
    }

    public static func toGroup(
        _ signal: ISO_9945.Kernel.Signal.Number,
        pgid: ISO_9945.Kernel.Process.Group.ID
    ) throws(ISO_9945.Kernel.Signal.Error) {

        guard pgid.underlying != 1, pgid.underlying != Int32.min else {
            throw .send(.posix(EINVAL))
        }
        guard kill(-pgid.underlying, signal.rawValue) == 0 else {
            throw .send(Error_Primitives.Error.captureErrno())
        }
    }
}
