public import ISO_9945_Core

#if canImport(Darwin)
    internal import Darwin
#elseif canImport(Glibc)
    internal import Glibc
#elseif canImport(Musl)
    internal import Musl
#endif

extension ISO_9945.Kernel.Socket {

    public enum Create {}
}

extension ISO_9945.Kernel.Socket.Create {

    public static func create(
        domain: ISO_9945.Kernel.Socket.Address.Family,
        kind: ISO_9945.Kernel.Socket.Kind,
        protocol: Int32 = 0
    ) throws(ISO_9945.Kernel.Socket.Error) -> ISO_9945.Kernel.Socket.Descriptor {
        let fd = socket(domain.rawValue, kind.rawValue, `protocol`)

        guard fd >= 0 else {
            throw ISO_9945.Kernel.Socket.Error.current()
        }

        return ISO_9945.Kernel.Socket.Descriptor(_raw: fd)
    }
}
