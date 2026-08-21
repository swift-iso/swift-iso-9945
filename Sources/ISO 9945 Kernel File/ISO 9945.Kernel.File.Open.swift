@_spi(Syscall) import ISO_9945_Core

#if canImport(Darwin)
    internal import Darwin
#elseif canImport(Glibc)
    internal import Glibc
#elseif canImport(Musl)
    internal import Musl
#endif

extension ISO_9945.Kernel.File.Open {

    public static func open(
        path: borrowing Path.Borrowed,
        mode: ISO_9945.Kernel.File.Open.Mode,
        options: ISO_9945.Kernel.File.Open.Options,
        permissions: ISO_9945.Kernel.File.Permissions
    ) throws(ISO_9945.Kernel.File.Open.Error) -> ISO_9945.Kernel.Descriptor {
        try unsafe path.withUnsafePointer { cString throws(ISO_9945.Kernel.File.Open.Error) in
            try unsafe _open(
                unsafePath: cString,
                mode: mode,
                options: options,
                permissions: permissions
            )
        }
    }

    @usableFromInline
    internal static func _open(
        unsafePath: UnsafePointer<Path.Char>,
        mode: ISO_9945.Kernel.File.Open.Mode,
        options: ISO_9945.Kernel.File.Open.Options,
        permissions: ISO_9945.Kernel.File.Permissions
    ) throws(ISO_9945.Kernel.File.Open.Error) -> ISO_9945.Kernel.Descriptor {
        let cPath = unsafe UnsafePointer<CChar>(unsafePath)

        guard mode.read || mode.write else {
            throw .platform(Error_Primitives.Error(code: .posix(EINVAL)))
        }
        let accessMode: Int32 =
            switch (mode.read, mode.write) {
            case (true, false): O_RDONLY
            case (false, true): O_WRONLY
            case (true, true): O_RDWR
            case (false, false): O_RDONLY
            }

        #if canImport(Darwin)
            let flags = accessMode | options.rawValue

            let fd = unsafe Darwin.open(cPath, flags, mode_t(permissions.rawValue))
            guard fd >= 0 else {
                throw ISO_9945.Kernel.File.Open.Error.current()
            }
        #elseif canImport(Musl)
            let flags = accessMode | options.rawValue
            let fd = unsafe Musl.open(cPath, flags, mode_t(permissions.rawValue))
            guard fd >= 0 else {
                throw ISO_9945.Kernel.File.Open.Error.current()
            }
        #elseif canImport(Glibc)
            let flags = accessMode | options.rawValue
            let fd = unsafe Glibc.open(cPath, flags, mode_t(permissions.rawValue))
            guard fd >= 0 else {
                throw ISO_9945.Kernel.File.Open.Error.current()
            }
        #endif

        return ISO_9945.Kernel.Descriptor(_rawValue: fd)
    }
}

extension ISO_9945.Kernel.File.Open.Error {

    @usableFromInline
    internal static func current() -> Self {
        Self(code: .posix(errno))
    }
}
