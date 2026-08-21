#if canImport(Darwin)
    internal import Darwin
#elseif canImport(Glibc)
    internal import Glibc
#elseif canImport(Musl)
    internal import Musl
#endif

extension ISO_9945.Kernel.Environment.Error {
    internal init(code: Error_Primitives.Error.Code) {
        if let e = ISO_9945.Kernel.Permission.Error(code: code) {
            self = .permission(e)
            return
        }

        self = .platform(Error_Primitives.Error(code: code))
    }

    internal static func current() -> Self {
        Self(code: .captureErrno())
    }
}
