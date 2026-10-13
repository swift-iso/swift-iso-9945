extension ISO_9945.Kernel.Socket.Message.Header {

    @safe
    public struct Control {

        public var pointer: UnsafeMutableRawBufferPointer?

        @unsafe
        public init(pointer: UnsafeMutableRawBufferPointer? = nil) {
            unsafe self.pointer = pointer
        }
    }
}
