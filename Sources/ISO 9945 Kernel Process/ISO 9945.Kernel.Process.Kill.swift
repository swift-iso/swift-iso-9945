#if canImport(Darwin)
    internal import Darwin
#elseif canImport(Glibc)
    internal import Glibc
#elseif canImport(Musl)
    internal import Musl
#endif

extension ISO_9945.Kernel.Process {

    public enum Kill {}
}

extension ISO_9945.Kernel.Process.Kill {

    public static func kill(
        _ process: ISO_9945.Kernel.Process.ID,
        _ signal: ISO_9945.Kernel.Signal.Number
    ) throws(ISO_9945.Kernel.Process.Error) {
        #if canImport(Darwin)
            let rc = Darwin.kill(process.rawValue, signal.rawValue)
        #elseif canImport(Glibc)
            let rc = Glibc.kill(process.rawValue, signal.rawValue)
        #elseif canImport(Musl)
            let rc = Musl.kill(process.rawValue, signal.rawValue)
        #endif

        if rc == -1 {
            throw .kill(Error_Primitives.Error.captureErrno())
        }
    }
}
