#if canImport(Darwin)
    internal import Darwin
#elseif canImport(Glibc)
    internal import Glibc
#elseif canImport(Musl)
    internal import Musl
#endif

extension Error.Error.Code {

    public var posixMessage: Swift.String? {
        switch self {
        case .posix(let rawValue):
            var buffer = [CChar](repeating: 0, count: 256)

            let result = unsafe strerror_r(rawValue, &buffer, buffer.count)
            guard result == 0 else { return nil }
            return buffer.withUnsafeBufferPointer {
                unsafe Swift.String(cString: $0.baseAddress!)
            }

        case .win32:
            return nil
        }
    }
}
