public import Kernel_Socket_Primitives

extension Kernel.Socket.Address {
    /// The byte length of a socket address.
    ///
    /// Mirrors POSIX `socklen_t` as a typed `Cardinal` carrying the
    /// "byte length of a sockaddr" domain. Used by `bind`, `connect`,
    /// `getsockname`, `getpeername`, `accept`, `recvfrom`, `sendto`, and
    /// the `static var size` accessors on `Address.Storage` /
    /// `Address.IPv4` / `Address.IPv6`.
    ///
    /// Backed by `Cardinal` (machine-word `UInt`); narrows to `socklen_t`
    /// (`UInt32`) at the C-call boundary.
    public typealias Length = Tagged<Kernel.Socket.Address, Cardinal>
}

// MARK: - Convenience Construction

extension Tagged where Tag == Kernel.Socket.Address, RawValue == Cardinal {
    /// Creates a length from a raw 32-bit unsigned value (POSIX `socklen_t`).
    @inlinable
    public init(_ socklen: UInt32) {
        self.init(UInt(socklen))
    }
}
