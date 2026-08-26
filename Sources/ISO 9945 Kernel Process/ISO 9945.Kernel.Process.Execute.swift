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

extension ISO_9945.Kernel.Process {

    public enum Execute {}
}

extension ISO_9945.Kernel.Process.Execute {

    @unsafe
    public static func execve(
        path: UnsafePointer<CChar>,
        argv: UnsafePointer<UnsafePointer<CChar>?>,
        envp: UnsafePointer<UnsafePointer<CChar>?>
    ) throws(ISO_9945.Kernel.Process.Error) {

        #if canImport(Darwin)
            _ = unsafe swift_execve(path, argv, envp)
        #elseif canImport(Glibc)
            _ = unsafe swift_execve(path, argv, envp)
        #elseif canImport(Musl)
            _ = unsafe Musl.execve(path, argv, envp)
        #endif
        throw .execute(Error.Error.captureErrno())
    }
}
