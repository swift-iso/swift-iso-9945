@_spi(Syscall) import ISO_9945_Core

#if canImport(Darwin)
    internal import Darwin
#elseif canImport(Glibc)
    internal import Glibc
#elseif canImport(Musl)
    internal import Musl
#endif

extension ISO_9945.Kernel.Descriptor.Duplicate {

    package static func duplicate(fd: Int32) throws(Error) -> Int32 {
        #if canImport(Darwin)
            let result = Darwin.dup(fd)
        #elseif canImport(Musl)
            let result = unsafe Musl.dup(fd)
        #elseif canImport(Glibc)
            let result = unsafe Glibc.dup(fd)
        #endif

        guard result >= 0 else {
            throw Error.current()
        }
        return result
    }

    @_spi(Syscall)
    public static func duplicate(
        fd: Int32,
        toFd newFd: Int32
    ) throws(Error) {
        #if canImport(Darwin)
            let result = Darwin.dup2(fd, newFd)
        #elseif canImport(Musl)
            let result = unsafe Musl.dup2(fd, newFd)
        #elseif canImport(Glibc)
            let result = unsafe Glibc.dup2(fd, newFd)
        #endif

        guard result >= 0 else {
            throw Error.current()
        }
    }
}

extension ISO_9945.Kernel.Descriptor.Duplicate {

    public static func duplicate(
        _ descriptor: borrowing ISO_9945.Kernel.Descriptor
    ) throws(Error) -> ISO_9945.Kernel.Descriptor {
        let rawNew = try duplicate(fd: descriptor._rawValue)
        return ISO_9945.Kernel.Descriptor(_rawValue: rawNew)
    }

    public static func duplicate(
        _ descriptor: borrowing ISO_9945.Kernel.Descriptor,
        to newDescriptor: inout ISO_9945.Kernel.Descriptor
    ) throws(Error) {
        try duplicate(fd: descriptor._rawValue, toFd: newDescriptor._rawValue)

    }
}

extension ISO_9945.Kernel.Descriptor.Duplicate.Error {

    internal static func current() -> Self {
        let code = Error.Error.Code.current()
        switch code {
        case .EBADF:
            return .handle(.invalid)

        case .EMFILE:
            return .tooManyOpen

        default:
            return .platform(Error.Error(code: code))
        }
    }
}

extension ISO_9945.Kernel.Descriptor.Duplicate.Error: CustomStringConvertible {
    public var description: Swift.String {
        switch self {
        case .handle(let e):
            return "handle: \(e)"

        case .tooManyOpen:
            return "Too many file descriptors open"

        case .platform(let e):
            return "\(e)"
        }
    }
}
