#if canImport(Darwin)
    internal import Darwin
#elseif canImport(Glibc)
    internal import Glibc
#elseif canImport(Musl)
    internal import Musl
#endif

extension ISO_9945.Kernel.User {

    public enum Login {}
}

extension ISO_9945.Kernel.User.Login {

    public enum Error: Swift.Error, Sendable, Equatable {
        case lookup(Error.Error.Code)
    }
}

extension ISO_9945.Kernel.User.Login.Error: CustomStringConvertible {
    public var description: Swift.String {
        switch self {
        case .lookup(let code):
            return "login name lookup failed: \(code)"
        }
    }
}

extension ISO_9945.Kernel.User.Login {

    private static let maximumBufferSize = 1 << 16

    public static func name() throws(Error) -> String? {
        var bufferSize = initialBufferSize()
        while true {
            var buffer = [CChar](repeating: 0, count: bufferSize)
            let rc = buffer.withUnsafeMutableBufferPointer { bufferPtr in
                unsafe getlogin_r(bufferPtr.baseAddress!, numericCast(bufferPtr.count))
            }

            if rc == 0 {
                return buffer.withUnsafeBufferPointer { bufferPtr in
                    unsafe String(cString: bufferPtr.baseAddress!)
                }
            }

            if rc == ERANGE, bufferSize < maximumBufferSize {
                bufferSize *= 2
                continue
            }

            if rc == ENXIO {
                return nil
            }

            throw .lookup(.posix(rc))
        }
    }

    private static func initialBufferSize() -> Int {
        256
    }
}
