@_spi(Syscall) import Kernel_Descriptor_Primitives
@_spi(Syscall) import Kernel_Socket_Primitives

extension ISO_9945.Kernel.Socket.Accept {
    /// Result of an accept operation.
    public struct Result: ~Copyable, Sendable {
        /// The new connected socket descriptor. The caller owns this descriptor.
        public var descriptor: Kernel.Socket.Descriptor

        /// The address of the connecting peer.
        public var address: Kernel.Socket.Address.Storage

        /// The length of the peer address.
        public var length: UInt32

        internal init(
            descriptor: consuming Kernel.Socket.Descriptor,
            address: Kernel.Socket.Address.Storage,
            length: UInt32
        ) {
            self.descriptor = descriptor
            self.address = address
            self.length = length
        }
    }
}
