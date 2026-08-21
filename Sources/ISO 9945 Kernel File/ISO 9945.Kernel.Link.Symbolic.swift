@_spi(Syscall) import ISO_9945_Core

#if canImport(Darwin)
    internal import Darwin
#elseif canImport(Glibc)
    internal import Glibc
#elseif canImport(Musl)
    internal import Musl
#endif

extension ISO_9945.Kernel.Link.Symbolic {

    @usableFromInline
    internal static func _create(
        target: UnsafePointer<Path.Char>,
        at linkPath: UnsafePointer<Path.Char>
    ) throws(Error) {
        let cTarget = unsafe UnsafePointer<CChar>(target)
        let cLinkPath = unsafe UnsafePointer<CChar>(linkPath)

        #if canImport(Darwin)
            let result = unsafe Darwin.symlink(cTarget, cLinkPath)
        #elseif canImport(Musl)
            let result = Musl.symlink(cTarget, cLinkPath)
        #elseif canImport(Glibc)
            let result = Glibc.symlink(cTarget, cLinkPath)
        #endif

        guard result == 0 else {
            throw Error.currentCreate()
        }
    }

    @usableFromInline
    internal static func _readTarget(
        at path: UnsafePointer<Path.Char>,
        into buffer: UnsafeMutableBufferPointer<CChar>
    ) throws(Error) -> Int {
        let cPath = unsafe UnsafePointer<CChar>(path)

        guard let base = buffer.baseAddress, buffer.count > 0 else {
            throw .bufferTooSmall
        }

        #if canImport(Darwin)
            let count = unsafe Darwin.readlink(cPath, base, buffer.count)
        #elseif canImport(Musl)
            let count = Musl.readlink(cPath, base, buffer.count)
        #elseif canImport(Glibc)
            let count = Glibc.readlink(cPath, base, buffer.count)
        #endif

        guard count >= 0 else {
            throw Error.currentRead()
        }

        return count
    }
}

extension ISO_9945.Kernel.Link.Symbolic {

    @_spi(Syscall)
    public static func create(
        target: UnsafePointer<Path.Char>,
        relativeToFd fd: Int32,
        linkPath: UnsafePointer<Path.Char>
    ) throws(Error) {
        let cTarget = unsafe UnsafePointer<CChar>(target)
        let cLinkPath = unsafe UnsafePointer<CChar>(linkPath)

        #if canImport(Darwin)
            let result = unsafe Darwin.symlinkat(cTarget, fd, cLinkPath)
        #elseif canImport(Musl)
            let result = unsafe Musl.symlinkat(cTarget, fd, cLinkPath)
        #elseif canImport(Glibc)
            let result = unsafe Glibc.symlinkat(cTarget, fd, cLinkPath)
        #endif

        guard result == 0 else {
            throw Error.currentCreate()
        }
    }
}

extension ISO_9945.Kernel.Link.Symbolic {

    @usableFromInline
    internal static func _create(
        target: UnsafePointer<Path.Char>,
        relativeTo descriptor: borrowing ISO_9945.Kernel.Descriptor,
        linkPath: UnsafePointer<Path.Char>
    ) throws(Error) {
        try unsafe create(
            target: target,
            relativeToFd: descriptor._rawValue,
            linkPath: linkPath
        )
    }
}

extension ISO_9945.Kernel.Link.Symbolic {

    public static func create(
        target: borrowing Path.Borrowed,
        at linkPath: borrowing Path.Borrowed
    ) throws(Error) {
        try unsafe target.withUnsafePointer { (targetPtr: UnsafePointer<Path.Char>) throws(Error) in
            try unsafe linkPath.withUnsafePointer {
                (linkPtr: UnsafePointer<Path.Char>) throws(Error) in
                try unsafe _create(target: targetPtr, at: linkPtr)
            }
        }
    }
}

extension ISO_9945.Kernel.Link.Symbolic {

    public static func withTargetBytes<R: ~Copyable>(
        at path: borrowing Path.Borrowed,
        _ body: (Swift.Span<Path.Char>) -> R
    ) throws(Error) -> R {
        try unsafe path.withUnsafePointer { cPath throws(Error) in
            var bufferSize = 256

            while bufferSize <= 65536 {
                let buffer = UnsafeMutablePointer<CChar>.allocate(capacity: bufferSize)
                defer { unsafe buffer.deallocate() }

                #if canImport(Darwin)
                    let count = unsafe Darwin.readlink(cPath, buffer, bufferSize)
                #elseif canImport(Musl)
                    let count = unsafe Musl.readlink(cPath, buffer, bufferSize)
                #elseif canImport(Glibc)
                    let count = unsafe Glibc.readlink(cPath, buffer, bufferSize)
                #endif

                guard count >= 0 else {
                    throw Error.currentRead()
                }

                if count < bufferSize {
                    let u8Ptr = unsafe UnsafePointer<UInt8>(buffer)
                    let span = unsafe Span(_unsafeStart: u8Ptr, count: count)
                    return body(span)
                }

                bufferSize *= 2
            }

            throw .bufferTooSmall
        }
    }

    public static func withTarget<R: ~Copyable>(
        at path: borrowing Path.Borrowed,
        _ body: (borrowing String.Borrowed) -> R
    ) throws(Error) -> R {
        try unsafe path.withUnsafePointer { cPath throws(Error) in
            var bufferSize = 256

            while bufferSize <= 65536 {

                let buffer = UnsafeMutablePointer<CChar>.allocate(capacity: bufferSize + 1)
                defer { unsafe buffer.deallocate() }

                #if canImport(Darwin)
                    let count = unsafe Darwin.readlink(cPath, buffer, bufferSize)
                #elseif canImport(Musl)
                    let count = unsafe Musl.readlink(cPath, buffer, bufferSize)
                #elseif canImport(Glibc)
                    let count = unsafe Glibc.readlink(cPath, buffer, bufferSize)
                #endif

                guard count >= 0 else {
                    throw Error.currentRead()
                }

                if count < bufferSize {
                    unsafe (buffer[count] = 0)
                    let u8Ptr = unsafe UnsafePointer<UInt8>(buffer)
                    let view = unsafe String.Borrowed(u8Ptr, count: count)
                    return body(view)
                }

                bufferSize *= 2
            }

            throw .bufferTooSmall
        }
    }

    public static func readTarget(at path: borrowing Path.Borrowed) throws(Error) -> String {
        try withTarget(at: path) { view in
            String(copying: view)
        }
    }
}

extension ISO_9945.Kernel.Link.Symbolic {
    public typealias Error = ISO_9945.Kernel.Link.Symbolic.Error
}

extension ISO_9945.Kernel.Link.Symbolic.Error {

    internal static func currentCreate() -> Self {
        let code = Error_Primitives.Error.Code.current()
        switch code {
        case .ENOENT:
            return .notFound

        case .EACCES, .EPERM:
            return .permission

        case .EEXIST:
            return .exists

        case .ENOTDIR:
            return .notDirectory

        case .EROFS:
            return .readOnly

        case .ENOSPC:
            return .noSpace

        case .ELOOP:
            return .loop

        case .ENAMETOOLONG:
            return .nameTooLong

        default:
            return .platform(Error_Primitives.Error(code: code))
        }
    }

    internal static func currentRead() -> Self {
        let code = Error_Primitives.Error.Code.current()
        switch code {
        case .ENOENT:
            return .notFound

        case .EACCES:
            return .permission

        case .EINVAL:
            return .notSymbolicLink

        case .ENOTDIR:
            return .notDirectory

        case .ELOOP:
            return .loop

        case .ENAMETOOLONG:
            return .nameTooLong

        default:
            return .platform(Error_Primitives.Error(code: code))
        }
    }
}
