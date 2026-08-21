#if canImport(Darwin)
    internal import Darwin
#elseif canImport(Glibc)
    internal import Glibc
#elseif canImport(Musl)
    internal import Musl
#endif

extension ISO_9945.Kernel.Directory.Working {

    public static func current(
        into buffer: UnsafeMutableBufferPointer<CChar>
    ) throws(ISO_9945.Kernel.Directory.Working.Error) -> Int {
        guard let base = buffer.baseAddress, buffer.count > 0 else {
            throw .invalidBuffer
        }

        #if canImport(Darwin)
            let result = unsafe Darwin.getcwd(base, buffer.count)
        #elseif canImport(Musl)
            let result = unsafe Musl.getcwd(base, buffer.count)
        #elseif canImport(Glibc)
            let result = unsafe Glibc.getcwd(base, buffer.count)
        #endif

        guard unsafe (result != nil) else {
            throw ISO_9945.Kernel.Directory.Working.Error.current()
        }

        var length = 0
        while length < buffer.count && (unsafe base[length]) != 0 {
            length += 1
        }

        return length
    }
}

extension ISO_9945.Kernel.Directory.Working {

    public static func withCurrentBytes<R: ~Copyable>(
        _ body: (Swift.Span<Path.Char>) -> R
    ) throws(ISO_9945.Kernel.Directory.Working.Error) -> R {

        var capacity = 4096
        let maxCapacity = 1 << 20

        while true {
            var result: R? = nil
            var thrown: ISO_9945.Kernel.Directory.Working.Error? = nil
            var rangeExceeded = false

            Swift.withUnsafeTemporaryAllocation(of: CChar.self, capacity: capacity) {
                buffer in
                guard let base = buffer.baseAddress, buffer.count > 0 else {
                    thrown = .invalidBuffer
                    return
                }

                #if canImport(Darwin)
                    let cwdResult = unsafe Darwin.getcwd(base, buffer.count)
                #elseif canImport(Musl)
                    let cwdResult = unsafe Musl.getcwd(base, buffer.count)
                #elseif canImport(Glibc)
                    let cwdResult = unsafe Glibc.getcwd(base, buffer.count)
                #endif

                guard unsafe (cwdResult != nil) else {
                    let code = Error_Primitives.Error.Code.current()
                    if case .posix(ERANGE) = code, capacity < maxCapacity {
                        rangeExceeded = true
                        return
                    }
                    thrown = ISO_9945.Kernel.Directory.Working.Error.current(code: code)
                    return
                }

                var length = 0
                while length < buffer.count && (unsafe base[length]) != 0 {
                    length += 1
                }

                let u8Ptr = unsafe UnsafePointer<UInt8>(base)
                let span = unsafe Span(_unsafeStart: u8Ptr, count: length)
                result = body(span)
            }

            if rangeExceeded {
                capacity *= 2
                continue
            }
            if let thrown { throw thrown }
            return result!
        }
    }

    public static func withCurrent<R: ~Copyable>(
        _ body: (borrowing String.Borrowed) -> R
    ) throws(ISO_9945.Kernel.Directory.Working.Error) -> R {

        var capacity = 4096
        let maxCapacity = 1 << 20

        while true {
            var result: R? = nil
            var thrown: ISO_9945.Kernel.Directory.Working.Error? = nil
            var rangeExceeded = false

            Swift.withUnsafeTemporaryAllocation(of: CChar.self, capacity: capacity) {
                buffer in
                guard let base = buffer.baseAddress, buffer.count > 0 else {
                    thrown = .invalidBuffer
                    return
                }

                #if canImport(Darwin)
                    let cwdResult = unsafe Darwin.getcwd(base, buffer.count)
                #elseif canImport(Musl)
                    let cwdResult = unsafe Musl.getcwd(base, buffer.count)
                #elseif canImport(Glibc)
                    let cwdResult = unsafe Glibc.getcwd(base, buffer.count)
                #endif

                guard unsafe (cwdResult != nil) else {
                    let code = Error_Primitives.Error.Code.current()
                    if case .posix(ERANGE) = code, capacity < maxCapacity {
                        rangeExceeded = true
                        return
                    }
                    thrown = ISO_9945.Kernel.Directory.Working.Error.current(code: code)
                    return
                }

                let u8Ptr = unsafe UnsafePointer<UInt8>(base)
                let view = unsafe String.Borrowed(u8Ptr, count: String.length(of: u8Ptr))
                result = body(view)
            }

            if rangeExceeded {
                capacity *= 2
                continue
            }
            if let thrown { throw thrown }
            return result!
        }
    }

    public static func current() throws(Error) -> String {
        try withCurrent { view in
            String(copying: view)
        }
    }
}

extension ISO_9945.Kernel.Directory.Working.Error {

    internal static func current(code: Error_Primitives.Error.Code) -> Self {
        if let pathError = Path.Resolution.Error(code: code) {
            return .path(pathError)
        }
        return .platform(Error_Primitives.Error(code: code))
    }

    internal static func current() -> Self {
        current(code: Error_Primitives.Error.Code.current())
    }
}
