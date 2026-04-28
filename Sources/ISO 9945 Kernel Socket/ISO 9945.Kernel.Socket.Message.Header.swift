@_spi(Syscall) import Kernel_Descriptor_Primitives
@_spi(Syscall) import Kernel_Socket_Primitives
public import ISO_9945_Kernel_File

#if canImport(Darwin)
    internal import Darwin
#elseif canImport(Glibc)
    internal import Glibc
#elseif canImport(Musl)
    internal import Musl
#endif

extension Kernel.Socket.Message {
    /// Message header for sendmsg/recvmsg operations.
    ///
    /// Wraps the platform `msghdr` struct. Layout-compatible — an
    /// `UnsafePointer<Header>` may be passed directly to kernel interfaces
    /// that expect `struct msghdr *`.
    public struct Header: @unchecked Sendable {
        /// The underlying C struct.
        internal var cValue: msghdr

        /// Creates a zeroed message header.
        public init() {
            unsafe self.cValue = msghdr()
        }
    }
}

// MARK: - Accessors

extension Kernel.Socket.Message.Header {
    /// Socket address for the message destination (sendmsg) or source (recvmsg).
    public var name: Name {
        get { unsafe Name(pointer: cValue.msg_name, length: Kernel.Socket.Address.Length(cValue.msg_namelen)) }
        set {
            unsafe cValue.msg_name = newValue.pointer
            unsafe cValue.msg_namelen = socklen_t(newValue.length.rawValue.rawValue)
        }
    }

    /// Scatter/gather I/O vectors.
    public var vectors: Vectors {
        get {
            unsafe Vectors(
                pointer: UnsafeMutableRawPointer(cValue.msg_iov)?.assumingMemoryBound(to: Kernel.IO.Vector.Segment.self),
                count: Int(cValue.msg_iovlen)
            )
        }
        set {
            unsafe cValue.msg_iov = UnsafeMutableRawPointer(newValue.pointer)?.assumingMemoryBound(to: iovec.self)
            cValue.msg_iovlen = numericCast(newValue.count)
        }
    }

    /// Ancillary data (control messages).
    public var control: Control {
        get {
            unsafe Control(
                pointer: cValue.msg_control.map { start in
                    UnsafeMutableRawBufferPointer(start: start, count: Int(cValue.msg_controllen))
                }
            )
        }
        set {
            unsafe cValue.msg_control = newValue.pointer?.baseAddress
            cValue.msg_controllen = numericCast(newValue.pointer?.count ?? 0)
        }
    }

    /// Flags on received message (output only, set by recvmsg).
    public var flags: Kernel.Socket.Message.Options {
        get { unsafe Kernel.Socket.Message.Options(rawValue: cValue.msg_flags) }
        set { unsafe cValue.msg_flags = newValue.rawValue }
    }
}
