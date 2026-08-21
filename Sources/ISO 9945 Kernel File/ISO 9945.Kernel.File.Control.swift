@_spi(Syscall) import ISO_9945_Core

#if canImport(Darwin)
    internal import Darwin
#elseif canImport(Glibc)
    internal import Glibc
#elseif canImport(Musl)
    internal import Musl
#endif

extension ISO_9945.Kernel.File.Control {

    @_spi(Syscall)
    public static func setNonBlocking(fd: Int32) throws(ISO_9945.Kernel.File.Control.Error) {
        #if canImport(Darwin)
            let flags = Darwin.fcntl(fd, F_GETFL)
            guard flags >= 0 else {
                throw Error.current()
            }
            let result = Darwin.fcntl(fd, F_SETFL, flags | O_NONBLOCK)
            guard result >= 0 else {
                throw Error.current()
            }
        #elseif canImport(Musl)
            let flags = unsafe Musl.fcntl(fd, F_GETFL)
            guard flags >= 0 else {
                throw Error.current()
            }
            let result = unsafe Musl.fcntl(fd, F_SETFL, flags | O_NONBLOCK)
            guard result >= 0 else {
                throw Error.current()
            }
        #elseif canImport(Glibc)
            let flags = unsafe Glibc.fcntl(fd, F_GETFL)
            guard flags >= 0 else {
                throw Error.current()
            }
            let result = unsafe Glibc.fcntl(fd, F_SETFL, flags | O_NONBLOCK)
            guard result >= 0 else {
                throw Error.current()
            }
        #else
            #error(
                "ISO_9945.Kernel.File.Control.setNonBlocking: unsupported platform (no Darwin, Glibc, or Musl)"
            )
        #endif
    }

    @_spi(Syscall)
    public static func setBlocking(fd: Int32) throws(ISO_9945.Kernel.File.Control.Error) {
        #if canImport(Darwin)
            let flags = Darwin.fcntl(fd, F_GETFL)
            guard flags >= 0 else {
                throw Error.current()
            }
            let result = Darwin.fcntl(fd, F_SETFL, flags & ~O_NONBLOCK)
            guard result >= 0 else {
                throw Error.current()
            }
        #elseif canImport(Musl)
            let flags = unsafe Musl.fcntl(fd, F_GETFL)
            guard flags >= 0 else {
                throw Error.current()
            }
            let result = unsafe Musl.fcntl(fd, F_SETFL, flags & ~O_NONBLOCK)
            guard result >= 0 else {
                throw Error.current()
            }
        #elseif canImport(Glibc)
            let flags = unsafe Glibc.fcntl(fd, F_GETFL)
            guard flags >= 0 else {
                throw Error.current()
            }
            let result = unsafe Glibc.fcntl(fd, F_SETFL, flags & ~O_NONBLOCK)
            guard result >= 0 else {
                throw Error.current()
            }
        #else
            #error(
                "ISO_9945.Kernel.File.Control.setBlocking: unsupported platform (no Darwin, Glibc, or Musl)"
            )
        #endif
    }
}

extension ISO_9945.Kernel.File.Control {

    public static func setNonBlocking(
        _ descriptor: borrowing ISO_9945.Kernel.Descriptor
    ) throws(ISO_9945.Kernel.File.Control.Error) {
        try setNonBlocking(fd: descriptor._rawValue)
    }

    public static func setBlocking(
        _ descriptor: borrowing ISO_9945.Kernel.Descriptor
    ) throws(ISO_9945.Kernel.File.Control.Error) {
        try setBlocking(fd: descriptor._rawValue)
    }
}

extension ISO_9945.Kernel.File.Control.Error {

    internal static func current() -> Self {
        let code = Error_Primitives.Error.Code.current()
        if let handleError = ISO_9945.Kernel.Descriptor.Validity.Error(code: code) {
            return .handle(handleError)
        }
        return .platform(Error_Primitives.Error(code: code))
    }
}
