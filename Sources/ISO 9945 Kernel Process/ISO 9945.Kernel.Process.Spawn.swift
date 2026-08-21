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

    public enum Spawn {}
}

extension ISO_9945.Kernel.Process.Spawn {

    @unsafe
    @_spi(Syscall)
    public static func spawn(
        path: UnsafePointer<CChar>,
        argv: UnsafePointer<UnsafePointer<CChar>?>,
        envp: UnsafePointer<UnsafePointer<CChar>?>
    ) throws(ISO_9945.Kernel.Process.Error) -> ISO_9945.Kernel.Process.ID {
        var pid: pid_t = 0

        let rc = unsafe swift_posix_spawn(
            &pid,
            path,
            nil,
            nil,
            argv,
            envp
        )

        guard rc == 0 else {
            throw .spawn(.posix(rc))
        }

        return ISO_9945.Kernel.Process.ID(pid)
    }

    @unsafe
    public static func spawn(
        path: UnsafePointer<Path.Char>,
        argv: UnsafePointer<UnsafePointer<Path.Char>?>,
        envp: UnsafePointer<UnsafePointer<Path.Char>?>
    ) throws(ISO_9945.Kernel.Process.Error) -> ISO_9945.Kernel.Process.ID {

        let pathCChar = unsafe UnsafePointer<CChar>(path)
        let argvCChar = unsafe UnsafeRawPointer(argv).assumingMemoryBound(
            to: UnsafePointer<CChar>?.self
        )
        let envpCChar = unsafe UnsafeRawPointer(envp).assumingMemoryBound(
            to: UnsafePointer<CChar>?.self
        )

        return try unsafe spawn(path: pathCChar, argv: argvCChar, envp: envpCChar)
    }

    @unsafe
    @_spi(Syscall)
    public static func spawn(
        path: UnsafePointer<CChar>,
        argv: UnsafePointer<UnsafePointer<CChar>?>,
        envp: UnsafePointer<UnsafePointer<CChar>?>,
        actions: borrowing Actions
    ) throws(ISO_9945.Kernel.Process.Error) -> ISO_9945.Kernel.Process.ID {
        var pid: pid_t = 0

        let rc = unsafe swift_posix_spawn(
            &pid,
            path,
            actions._handle,
            nil,
            argv,
            envp
        )

        guard rc == 0 else {
            throw .spawn(.posix(rc))
        }

        return ISO_9945.Kernel.Process.ID(pid)
    }

    @unsafe
    public static func spawn(
        path: UnsafePointer<Path.Char>,
        argv: UnsafePointer<UnsafePointer<Path.Char>?>,
        envp: UnsafePointer<UnsafePointer<Path.Char>?>,
        actions: borrowing Actions
    ) throws(ISO_9945.Kernel.Process.Error) -> ISO_9945.Kernel.Process.ID {
        let pathCChar = unsafe UnsafePointer<CChar>(path)
        let argvCChar = unsafe UnsafeRawPointer(argv).assumingMemoryBound(
            to: UnsafePointer<CChar>?.self
        )
        let envpCChar = unsafe UnsafeRawPointer(envp).assumingMemoryBound(
            to: UnsafePointer<CChar>?.self
        )

        return try unsafe spawn(
            path: pathCChar,
            argv: argvCChar,
            envp: envpCChar,
            actions: actions
        )
    }
}
