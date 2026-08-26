@_spi(Syscall) import ISO_9945_Core

#if canImport(Darwin)
    internal import Darwin
#elseif canImport(Glibc)
    internal import Glibc
#elseif canImport(Musl)
    internal import Musl
#endif

extension ISO_9945.Kernel.File.Flush {

    @_spi(Syscall)
    public static func fsync(fd: Int32) throws(Error) {
        #if canImport(Darwin)
            let result = Darwin.fsync(fd)
        #elseif canImport(Musl)
            let result = unsafe Musl.fsync(fd)
        #elseif canImport(Glibc)
            let result = unsafe Glibc.fsync(fd)
        #endif

        if result == 0 {
            return
        }

        throw Error.current()
    }

    #if canImport(Glibc) || canImport(Musl)

        @_spi(Syscall)
        public static func fdatasync(fd: Int32) throws(Error) {
            #if canImport(Musl)
                let result = unsafe Musl.fdatasync(fd)
            #elseif canImport(Glibc)
                let result = unsafe Glibc.fdatasync(fd)
            #endif

            if result == 0 {
                return
            }

            throw Error.current()
        }
    #endif

    #if canImport(Darwin)

        @_spi(Syscall)
        public static func fullFsync(fd: Int32) throws(Error) {
            let result = Darwin.fcntl(fd, F_FULLFSYNC)

            if result != -1 {
                return
            }

            throw Error.current()
        }

        @_spi(Syscall)
        public static func barrierFsync(fd: Int32) throws(Error) {
            let result = Darwin.fcntl(fd, F_BARRIERFSYNC)

            if result != -1 {
                return
            }

            throw Error.current()
        }
    #endif
}

extension ISO_9945.Kernel.File.Flush {

    public static func fsync(_ descriptor: borrowing ISO_9945.Kernel.Descriptor) throws(Error) {
        try fsync(fd: descriptor._rawValue)
    }

    #if canImport(Glibc) || canImport(Musl)

        public static func fdatasync(
            _ descriptor: borrowing ISO_9945.Kernel.Descriptor
        ) throws(Error) {
            try unsafe fdatasync(fd: descriptor._rawValue)
        }
    #endif

    #if canImport(Darwin)

        public static func fullFsync(
            _ descriptor: borrowing ISO_9945.Kernel.Descriptor
        ) throws(Error) {
            try fullFsync(fd: descriptor._rawValue)
        }

        public static func barrierFsync(
            _ descriptor: borrowing ISO_9945.Kernel.Descriptor
        ) throws(Error) {
            try barrierFsync(fd: descriptor._rawValue)
        }
    #endif
}

extension ISO_9945.Kernel.File.Flush {
    public typealias Error = ISO_9945.Kernel.File.Flush.Error
}

extension ISO_9945.Kernel.File.Flush.Error {

    internal static func current() -> Self {
        let code = Error.Error.Code.current()
        if let handleError = ISO_9945.Kernel.Descriptor.Validity.Error(code: code) {
            return .handle(handleError)
        }
        return .platform(Error.Error(code: code))
    }
}
