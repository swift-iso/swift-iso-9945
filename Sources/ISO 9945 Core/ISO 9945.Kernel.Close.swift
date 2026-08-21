#if canImport(Darwin)
    internal import Darwin
#elseif canImport(Glibc)
    internal import Glibc
#elseif canImport(Musl)
    internal import Musl
#endif

extension ISO_9945.Kernel {

    public enum Close: Sendable {}
}

extension ISO_9945.Kernel.Close {

    public static func close(_ descriptor: consuming ISO_9945.Kernel.Descriptor) throws(Error) {
        guard descriptor.isValid else {
            throw .handle(.invalid)
        }
        let raw = descriptor._raw

        descriptor._raw = -1

        let result: Int32
        #if canImport(Darwin)
            result = Darwin.close(raw)
        #elseif canImport(Glibc)
            result = unsafe Glibc.close(raw)
        #elseif canImport(Musl)
            result = unsafe Musl.close(raw)
        #endif
        if result == -1 {
            throw .platform(Error_Primitives.Error(code: .posix(errno)))
        }
    }
}
