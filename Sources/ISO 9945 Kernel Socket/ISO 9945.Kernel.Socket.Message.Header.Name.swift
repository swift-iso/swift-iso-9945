@_spi(Syscall) import Kernel_Socket_Primitives

extension Kernel.Socket.Message.Header {
    /// Socket address component of a message header.
    public struct Name: @unchecked Sendable {
        /// Pointer to the socket address structure.
        public var pointer: UnsafeMutableRawPointer?

        /// Length of the socket address in bytes.
        public var length: UInt32

        /// Creates a socket address descriptor.
        ///
        /// - Parameters:
        ///   - pointer: Pointer to the socket address structure.
        ///   - length: Length of the socket address in bytes.
        @unsafe
        public init(pointer: UnsafeMutableRawPointer? = nil, length: UInt32 = 0) {
            unsafe self.pointer = pointer
            self.length = length
        }
    }
}
