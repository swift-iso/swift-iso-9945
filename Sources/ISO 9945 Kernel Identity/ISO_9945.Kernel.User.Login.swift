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

    private static let maximumBufferSize = 1 << 16

    public static func name() throws(Error) -> String? {
        var bufferSize = initialBufferSize()
        while true {
            var buffer = [CChar](repeating: 0, count: bufferSize)
            let rc = buffer.withUnsafeMutableBufferPointer { bufferPtr in
                guard let base = unsafe bufferPtr.baseAddress else {
                    preconditionFailure("login buffer is non-empty")
                }
                return unsafe getlogin_r(base, numericCast(bufferPtr.count))
            }

            if rc == 0 {
                return buffer.withUnsafeBufferPointer { bufferPtr in
                    guard let base = unsafe bufferPtr.baseAddress else {
                        preconditionFailure("login buffer is non-empty")
                    }
                    return unsafe String(cString: base)
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
