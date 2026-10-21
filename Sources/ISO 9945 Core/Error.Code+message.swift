#if canImport(Darwin)
    internal import Darwin
#elseif canImport(Glibc)
    internal import Glibc
#elseif canImport(Musl)
    internal import Musl
#endif

extension Error::Error.Code {

    public var posixMessage: Swift::String? {
        switch self {
        case .posix(let rawValue):
            var buffer = [CChar](repeating: 0, count: 256)

            let result = unsafe strerror_r(rawValue, &buffer, buffer.count)
            guard result == 0 else { return nil }
            return buffer.withUnsafeBufferPointer { (pointer: UnsafeBufferPointer<CChar>) -> Swift::String in
                guard let base = unsafe pointer.baseAddress else {
                    preconditionFailure("A non-empty buffer has a base address")
                }
                return unsafe Swift::String(cString: base)
            }

        case .win32:
            return nil
        }
    }
}
