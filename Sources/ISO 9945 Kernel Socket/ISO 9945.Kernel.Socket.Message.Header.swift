public import ISO_9945_Kernel_File

#if canImport(Darwin)
    internal import Darwin
#elseif canImport(Glibc)
    internal import Glibc
#elseif canImport(Musl)
    internal import Musl
#endif

extension ISO_9945.Kernel.Socket.Message {

    public struct Header {

        internal var cValue: msghdr

        public init() {
            unsafe self.cValue = msghdr()
        }
    }
}

extension ISO_9945.Kernel.Socket.Message.Header {

    public var name: Name {
        get {
            unsafe Name(
                pointer: cValue.msg_name,
                length: ISO_9945.Kernel.Socket.Address.Length(cValue.msg_namelen)
            )
        }
        set {
            unsafe cValue.msg_name = newValue.pointer
            unsafe cValue.msg_namelen = socklen_t(newValue.length.underlying.rawValue)
        }
    }

    public var vectors: Vectors {
        get {
            unsafe Vectors(
                pointer: UnsafeMutableRawPointer(cValue.msg_iov)?.assumingMemoryBound(
                    to: ISO_9945.Kernel.IO.Vector.Segment.self
                ),
                count: Int(cValue.msg_iovlen)
            )
        }
        set {
            unsafe cValue.msg_iov = UnsafeMutableRawPointer(newValue.pointer)?.assumingMemoryBound(
                to: iovec.self
            )
            unsafe cValue.msg_iovlen = numericCast(newValue.count)
        }
    }

    public var control: Control {
        get {
            unsafe Control(
                pointer: cValue.msg_control.map { start in
                    unsafe UnsafeMutableRawBufferPointer(
                        start: start,
                        count: Int(cValue.msg_controllen)
                    )
                }
            )
        }
        set {
            unsafe cValue.msg_control = newValue.pointer?.baseAddress
            unsafe cValue.msg_controllen = unsafe numericCast(newValue.pointer?.count ?? 0)
        }
    }

    public var flags: ISO_9945.Kernel.Socket.Message.Options {
        get { unsafe ISO_9945.Kernel.Socket.Message.Options(rawValue: cValue.msg_flags) }
        set { unsafe cValue.msg_flags = newValue.rawValue }
    }
}
