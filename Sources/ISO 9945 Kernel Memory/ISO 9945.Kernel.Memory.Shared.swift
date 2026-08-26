@_spi(Syscall) import ISO_9945_Core
import Memory

#if canImport(Darwin)
    internal import Darwin
    internal import ISO_9945_Shims
#elseif canImport(Glibc)
    internal import Glibc
#elseif canImport(Musl)
    internal import Musl
#endif

extension Memory.Shared {

    @_spi(Syscall) @unsafe
    public static func shm_open(
        name: UnsafePointer<CChar>,
        access: Memory.Shared.Access,
        options: Memory.Shared.Options = [],
        permissions: ISO_9945.Kernel.File.Permissions = .ownerReadWrite
    ) throws(Memory.Shared.Error) -> Int32 {

        guard access.read || access.write else {
            throw .open(.posix(EINVAL))
        }
        let accessMode: Int32 =
            switch (access.read, access.write) {
            case (true, false): O_RDONLY
            case (false, true): O_WRONLY
            case (true, true): O_RDWR
            case (false, false): O_RDONLY
            }

        let flags = accessMode | options.rawValue

        #if canImport(Darwin)

            let fd = unsafe iso9945_shm_open(name, flags, mode_t(permissions.rawValue))
        #elseif canImport(Glibc)

            let fd = unsafe Glibc.shm_open(name, flags, mode_t(permissions.rawValue))
        #elseif canImport(Musl)
            let fd = unsafe Musl.shm_open(name, flags, mode_t(permissions.rawValue))
        #endif

        guard fd >= 0 else {
            throw .open(Error.Error.Code.captureErrno())
        }
        return fd
    }

    @unsafe
    public static func open(
        name: UnsafePointer<CChar>,
        access: Memory.Shared.Access,
        options: Memory.Shared.Options = [],
        permissions: ISO_9945.Kernel.File.Permissions = .ownerReadWrite
    ) throws(Memory.Shared.Error) -> ISO_9945.Kernel.Descriptor {
        let fd = try unsafe shm_open(
            name: name,
            access: access,
            options: options,
            permissions: permissions
        )
        return ISO_9945.Kernel.Descriptor(_rawValue: fd)
    }

    @unsafe
    public static func unlink(name: UnsafePointer<CChar>) throws(Memory.Shared.Error) {
        guard unsafe shm_unlink(name) == 0 else {
            throw .unlink(Error.Error.Code.captureErrno())
        }
    }
}
