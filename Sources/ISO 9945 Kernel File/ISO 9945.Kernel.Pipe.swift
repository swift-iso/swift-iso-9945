@_spi(Syscall) import ISO_9945_Core

#if canImport(Darwin)
    internal import Darwin
#elseif canImport(Glibc)
    internal import Glibc
#elseif canImport(Musl)
    internal import Musl
#endif

extension ISO_9945.Kernel.Pipe {

    public typealias Descriptors = Tagged<
        ISO_9945.Kernel.Pipe, Pair<ISO_9945.Kernel.Descriptor, ISO_9945.Kernel.Descriptor>
    >
}

extension Tagged
where
    Tag == ISO_9945.Kernel.Pipe,
    Underlying == Pair<ISO_9945.Kernel.Descriptor, ISO_9945.Kernel.Descriptor>
{

    public var read: ISO_9945.Kernel.Descriptor {
        @inlinable _read { yield underlying.first }
    }

    public var write: ISO_9945.Kernel.Descriptor {
        @inlinable _read { yield underlying.second }
    }

    @inlinable
    package init(
        read: consuming ISO_9945.Kernel.Descriptor,
        write: consuming ISO_9945.Kernel.Descriptor
    ) {
        self.init(_unchecked: Pair(read, write))
    }
}

extension ISO_9945.Kernel.Pipe {

    public static func pipe() throws(Error) -> Descriptors {
        var fds: (Int32, Int32) = (0, 0)

        let result = withUnsafeMutablePointer(to: &fds) { ptr in
            unsafe ptr.withMemoryRebound(to: Int32.self, capacity: 2) { fdPtr in
                #if canImport(Darwin)
                    unsafe Darwin.pipe(fdPtr)
                #elseif canImport(Musl)
                    Musl.pipe(fdPtr)
                #elseif canImport(Glibc)
                    Glibc.pipe(fdPtr)
                #endif
            }
        }

        guard result == 0 else {
            throw Error.current()
        }

        return Descriptors(
            read: ISO_9945.Kernel.Descriptor(_rawValue: fds.0),
            write: ISO_9945.Kernel.Descriptor(_rawValue: fds.1)
        )
    }

}

extension ISO_9945.Kernel.Pipe {
    public typealias Error = ISO_9945.Kernel.Pipe.Error
}

extension ISO_9945.Kernel.Pipe.Error {

    internal static func current() -> Self {
        let code = Error_Primitives.Error.Code.current()
        if let handleError = ISO_9945.Kernel.Descriptor.Validity.Error(code: code) {
            return .handle(handleError)
        }
        return .platform(Error_Primitives.Error(code: code))
    }
}
