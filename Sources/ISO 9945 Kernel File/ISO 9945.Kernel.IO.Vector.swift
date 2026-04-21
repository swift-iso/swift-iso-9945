@_spi(Syscall) import Kernel_Descriptor_Primitives
@_spi(Syscall) import Kernel_File_Primitives

#if canImport(Darwin)
    internal import Darwin
#elseif canImport(Glibc)
    internal import Glibc
#elseif canImport(Musl)
    internal import Musl
#endif

extension ISO_9945.Kernel.IO {
    /// Vector (scatter/gather) I/O namespace.
    public enum Vector {}
}

// MARK: - Scatter Read

extension ISO_9945.Kernel.IO.Vector {
    /// Reads data from a file descriptor into multiple buffers (scatter read).
    ///
    /// Atomically reads into a sequence of buffers in order. The kernel fills
    /// each buffer completely before moving to the next, except on EOF.
    ///
    /// - Parameters:
    ///   - descriptor: The file descriptor to read from.
    ///   - buffers: Array of ``Segment`` values describing receive buffers.
    /// - Returns: Total number of bytes read across all buffers.
    /// - Throws: `Kernel.IO.Read.Error` on failure.
    ///
    /// ## Usage
    ///
    /// Scatter read is useful for protocol parsing where header and body
    /// are separate buffers, or when reading into non-contiguous memory.
    public static func read(
        _ descriptor: borrowing Kernel.Descriptor,
        buffers: [Segment]
    ) throws(Kernel.IO.Read.Error) -> Int {
        guard descriptor.isValid else {
            throw .handle(.invalid)
        }

        let iovecs = buffers.map { $0.cValue }
        let result = unsafe iovecs.withUnsafeBufferPointer { buf in
            unsafe readv(descriptor._rawValue, buf.baseAddress!, Int32(buf.count))
        }

        guard result >= 0 else {
            throw Kernel.IO.Read.Error.current()
        }

        return result
    }
}

// MARK: - Gather Write

extension ISO_9945.Kernel.IO.Vector {
    /// Writes data from multiple buffers to a file descriptor (gather write).
    ///
    /// Atomically writes from a sequence of buffers in order. The kernel
    /// writes each buffer completely before moving to the next.
    ///
    /// - Parameters:
    ///   - descriptor: The file descriptor to write to.
    ///   - buffers: Array of ``Segment`` values describing send buffers.
    /// - Returns: Total number of bytes written across all buffers.
    /// - Throws: `Kernel.IO.Write.Error` on failure.
    ///
    /// ## Usage
    ///
    /// Gather write avoids copying header + body into a contiguous buffer
    /// before writing. Critical for high-throughput network protocols.
    public static func write(
        _ descriptor: borrowing Kernel.Descriptor,
        buffers: [Segment]
    ) throws(Kernel.IO.Write.Error) -> Int {
        guard descriptor.isValid else {
            throw .handle(.invalid)
        }

        let iovecs = buffers.map { $0.cValue }
        let result = unsafe iovecs.withUnsafeBufferPointer { buf in
            unsafe writev(descriptor._rawValue, buf.baseAddress!, Int32(buf.count))
        }

        guard result >= 0 else {
            throw Kernel.IO.Write.Error.current()
        }

        return result
    }
}
