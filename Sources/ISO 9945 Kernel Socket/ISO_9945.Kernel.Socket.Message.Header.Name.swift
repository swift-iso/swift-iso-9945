extension ISO_9945.Kernel.Socket.Message.Header {

    public struct Name {

        public var pointer: UnsafeMutableRawPointer?

        public var length: ISO_9945.Kernel.Socket.Address.Length

        @unsafe
        public init(
            pointer: UnsafeMutableRawPointer? = nil,
            length: ISO_9945.Kernel.Socket.Address.Length = ISO_9945.Kernel.Socket.Address.Length(
                UInt(0)
            )
        ) {
            unsafe self.pointer = pointer
            self.length = length
        }
    }
}
