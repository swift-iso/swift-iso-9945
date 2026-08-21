extension ISO_9945.Kernel.Socket.Message.Header {

    public struct Control {

        public var pointer: UnsafeMutableRawBufferPointer?

        @unsafe
        public init(pointer: UnsafeMutableRawBufferPointer? = nil) {
            unsafe self.pointer = pointer
        }
    }
}
