extension ISO_9945.Kernel.Socket.Accept {

    @frozen
    public struct Result: ~Copyable, Sendable {

        public var descriptor: ISO_9945.Kernel.Socket.Descriptor

        public var address: ISO_9945.Kernel.Socket.Address.Storage

        public var length: ISO_9945.Kernel.Socket.Address.Length

        @inlinable
        package init(
            descriptor: consuming ISO_9945.Kernel.Socket.Descriptor,
            address: ISO_9945.Kernel.Socket.Address.Storage,
            length: ISO_9945.Kernel.Socket.Address.Length
        ) {
            self.descriptor = descriptor
            self.address = address
            self.length = length
        }
    }
}
