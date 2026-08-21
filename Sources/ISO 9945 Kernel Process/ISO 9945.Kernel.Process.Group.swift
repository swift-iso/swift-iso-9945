#if canImport(Darwin)
    internal import Darwin
#elseif canImport(Glibc)
    internal import Glibc
#elseif canImport(Musl)
    internal import Musl
#endif

extension ISO_9945.Kernel.Process.Group {

    public static func set(
        _ process: Process,
        to target: Target
    ) throws(ISO_9945.Kernel.Process.Error) {
        let pid: pid_t =
            switch process {
            case .current:
                0

            case .id(let id):
                id.rawValue
            }

        let pgid: pid_t =
            switch target {
            case .same:
                0

            case .id(let id):
                id.underlying
            }

        guard setpgid(pid, pgid) == 0 else {
            throw .group(Error_Primitives.Error.captureErrno())
        }
    }

    public static func id(
        of pid: ISO_9945.Kernel.Process.ID
    ) throws(ISO_9945.Kernel.Process.Error) -> ID {
        let result = getpgid(pid.rawValue)
        guard result != -1 else {
            throw .group(Error_Primitives.Error.captureErrno())
        }
        return ID(_unchecked: result)
    }
}
