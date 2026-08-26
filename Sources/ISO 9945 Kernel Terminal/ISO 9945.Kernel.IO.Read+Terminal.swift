#if !os(Windows)

    #if canImport(Darwin)
        internal import Darwin
    #elseif canImport(Glibc)
        internal import Glibc
    #elseif canImport(Musl)
        internal import Musl
    #endif

    extension ISO_9945.Kernel.IO.Read {

        public static func read(
            _ stream: Terminal.Stream,
            into buffer: UnsafeMutableRawBufferPointer
        ) throws(Error) -> Int {
            guard let baseAddress = buffer.baseAddress else {
                return 0
            }
            #if canImport(Darwin)
                return try Syscall.require(
                    unsafe Darwin.read(stream.rawValue, baseAddress, buffer.count),
                    .nonNegative,
                    orThrow: Error.current()
                )
            #elseif canImport(Musl)
                return try Syscall.require(
                    unsafe Musl.read(stream.rawValue, baseAddress, buffer.count),
                    .nonNegative,
                    orThrow: Error.current()
                )
            #elseif canImport(Glibc)
                return try Syscall.require(
                    unsafe Glibc.read(stream.rawValue, baseAddress, buffer.count),
                    .nonNegative,
                    orThrow: Error.current()
                )
            #endif
        }
    }

    extension ISO_9945.Kernel.IO.Read.Error {

        fileprivate static func current() -> Self {
            let code = Error.Error.Code.current()
            if let handleError = ISO_9945.Kernel.Descriptor.Validity.Error(code: code) {
                return .handle(handleError)
            }
            if let blockingError = ISO_9945.Kernel.IO.Blocking.Error(code: code) {
                return .blocking(blockingError)
            }
            return .platform(Error.Error(code: code))
        }
    }

#endif
