#if canImport(Darwin)
    internal import Darwin
    internal import POSIX_Process_Shims
#elseif canImport(Glibc)
    internal import Glibc
    internal import POSIX_Process_Shims
#elseif canImport(Musl)
    internal import Musl
    internal import POSIX_Process_Shims
#endif

extension ISO_9945.Kernel.Process.Status {

    public enum Classification: Sendable, Equatable {

        case exited(code: Int32)

        case signaled(signal: ISO_9945.Kernel.Signal.Number, Bool)

        case stopped(signal: ISO_9945.Kernel.Signal.Number)

        case continued
    }

    public var classification: Classification? {
        if exited, let code = exit.code {
            return .exited(code: code)
        }
        if signaled, let signal = terminating.signal {
            return .signaled(signal: signal, core.dumped)
        }
        if stopped, let signal = stop.signal {
            return .stopped(signal: signal)
        }
        if continued {
            return .continued
        }
        return nil
    }
}
