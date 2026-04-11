@_spi(Syscall) import Kernel_Socket_Primitives

extension Kernel.Socket.Message.Header {
    /// I/O vector component of a message header.
    ///
    /// Each element in the pointed-to array describes one buffer segment.
    /// The memory must be layout-compatible with `struct iovec`.
    public struct Vectors: @unchecked Sendable {
        /// Pointer to the I/O vector array.
        public var pointer: UnsafeMutableRawPointer?

        /// Number of I/O vectors.
        public var count: Int

        /// Creates an I/O vector descriptor.
        ///
        /// - Parameters:
        ///   - pointer: Pointer to the I/O vector array.
        ///   - count: Number of I/O vectors.
        public init(pointer: UnsafeMutableRawPointer? = nil, count: Int = 0) {
            unsafe self.pointer = pointer
            self.count = count
        }
    }
}
