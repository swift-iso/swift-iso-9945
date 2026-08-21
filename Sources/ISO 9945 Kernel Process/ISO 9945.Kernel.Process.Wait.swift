#if canImport(Darwin)
    internal import Darwin
#elseif canImport(Glibc)
    internal import Glibc
#elseif canImport(Musl)
    internal import Musl
#endif

extension ISO_9945.Kernel.Process {

    public enum Wait {}
}

extension ISO_9945.Kernel.Process.Wait {

    public static func wait(
        _ selector: Selector,
        options: Options = []
    ) throws(ISO_9945.Kernel.Process.Error) -> Result? {
        let pid: pid_t
        switch selector {
        case .any:
            pid = -1

        case .process(let id):
            pid = id.rawValue

        case .group(let pgid):

            guard pgid.underlying != pid_t.min else {
                throw .wait(.posix(EINVAL))
            }
            pid = -pgid.underlying

        case .current:
            pid = 0
        }

        var status: Int32 = 0
        let result = unsafe waitpid(pid, &status, options.rawValue)

        if result == -1 {
            throw .wait(Error_Primitives.Error.captureErrno())
        }

        if result == 0 {
            return nil
        }

        return Result(
            pid: ISO_9945.Kernel.Process.ID(result),
            status: ISO_9945.Kernel.Process.Status(rawValue: status)
        )
    }
}
