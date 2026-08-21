#if canImport(Darwin)
    internal import Darwin
#elseif canImport(Glibc)
    internal import Glibc
#elseif canImport(Musl)
    internal import Musl
#endif

extension ISO_9945.Kernel.Signal {

    public enum Mask {}
}

extension ISO_9945.Kernel.Signal.Mask {

    public static func change(
        _ how: How,
        signals: ISO_9945.Kernel.Signal.Set
    ) throws(ISO_9945.Kernel.Signal.Error) -> ISO_9945.Kernel.Signal.Set {
        var previous = sigset_t()
        unsafe sigemptyset(&previous)

        let error = unsafe signals.withUnsafePointer { setPtr in
            unsafe pthread_sigmask(how.rawValue, setPtr, &previous)
        }

        guard error == 0 else {
            throw .mask(.posix(error))
        }

        return ISO_9945.Kernel.Signal.Set(storage: previous)
    }

    public static func pending() throws(ISO_9945.Kernel.Signal.Error) -> ISO_9945.Kernel.Signal.Set
    {
        var set = sigset_t()
        unsafe sigemptyset(&set)

        guard unsafe sigpending(&set) == 0 else {
            throw .mask(Error_Primitives.Error.captureErrno())
        }

        return ISO_9945.Kernel.Signal.Set(storage: set)
    }
}
