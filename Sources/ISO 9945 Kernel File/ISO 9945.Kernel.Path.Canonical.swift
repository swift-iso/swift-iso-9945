#if canImport(Darwin)
    internal import Darwin
#elseif canImport(Glibc)
    internal import Glibc
#elseif canImport(Musl)
    internal import Musl
#endif

extension Path.Canonical {

    public static func withCanonicalBytes<R: ~Copyable>(
        _ path: borrowing Path.Borrowed,
        _ body: (Swift.Span<Path.Char>) -> R
    ) throws(Path.Canonical.Error) -> R {
        try unsafe path.withUnsafePointer { cString throws(Path.Canonical.Error) in
            let unsafePath = unsafe UnsafePointer<CChar>(cString)

            #if canImport(Darwin)
                let result = unsafe Darwin.realpath(unsafePath, nil)
            #elseif canImport(Musl)
                let result = Musl.realpath(unsafePath, nil)
            #elseif canImport(Glibc)
                let result = Glibc.realpath(unsafePath, nil)
            #endif

            guard let result = unsafe result else {
                throw .current()
            }

            defer { unsafe free(result) }

            var length = 0
            while (unsafe result[length]) != 0 {
                length += 1
            }

            let u8Ptr = unsafe UnsafePointer<UInt8>(result)
            let span = unsafe Span(_unsafeStart: u8Ptr, count: length)
            return body(span)
        }
    }

    public static func withCanonical<R: ~Copyable>(
        _ path: borrowing Path.Borrowed,
        _ body: (borrowing String.Borrowed) -> R
    ) throws(Path.Canonical.Error) -> R {
        try unsafe path.withUnsafePointer { cString throws(Path.Canonical.Error) in
            let unsafePath = unsafe UnsafePointer<CChar>(cString)

            #if canImport(Darwin)
                let result = unsafe Darwin.realpath(unsafePath, nil)
            #elseif canImport(Musl)
                let result = unsafe Musl.realpath(unsafePath, nil)
            #elseif canImport(Glibc)
                let result = unsafe Glibc.realpath(unsafePath, nil)
            #endif

            guard let result = unsafe result else {
                throw .current()
            }

            defer { unsafe free(result) }

            let u8Ptr = unsafe UnsafePointer<UInt8>(result)
            let view = unsafe String.Borrowed(u8Ptr, count: String.length(of: u8Ptr))
            return body(view)
        }
    }

    public static func canonicalize(
        _ path: borrowing Path.Borrowed
    ) throws(Path.Canonical.Error) -> String {
        try withCanonical(path) { view in
            String(copying: view)
        }
    }
}

extension Path.Canonical.Error {

    static func current() -> Path.Canonical.Error {
        let e = errno
        let code = Error.Error.Code.posix(e)
        if let pathError = Path.Resolution.Error(code: code) {
            return .path(pathError)
        }
        return .platform(Error.Error(code: code))
    }
}
