public import ISO_9945_Kernel_File

extension ISO_9945.Kernel.Socket.Message.Header {

    public struct Vectors {

        public var pointer: UnsafeMutablePointer<ISO_9945.Kernel.IO.Vector.Segment>?

        public var count: Int

        @unsafe
        public init(
            pointer: UnsafeMutablePointer<ISO_9945.Kernel.IO.Vector.Segment>? = nil,
            count: Int = 0
        ) {
            unsafe self.pointer = pointer
            self.count = count
        }
    }
}
