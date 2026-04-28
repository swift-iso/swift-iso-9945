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

// MARK: - Scatter Read (raw @_spi(Syscall))

extension ISO_9945.Kernel.IO.Vector {
    /// Reads data from a raw file descriptor into multiple buffers (scatter read).
    ///
    /// Spec-literal raw `readv(2)`. Atomically reads into a sequence of buffers
    /// in order; the kernel fills each buffer completely before moving to the
    /// next, except on EOF. The typed L2 convenience
    /// (`ISO_9945.Kernel.IO.Vector.read(_:buffers:)` taking
    /// `borrowing Kernel.Descriptor`) delegates to this raw SPI internally.
    ///
    /// - Parameters:
    ///   - fd: The raw file descriptor to read from.
    ///   - buffers: Array of ``Segment`` values describing receive buffers.
    /// - Returns: Total number of bytes read across all buffers.
    /// - Throws: `Kernel.IO.Read.Error` on failure.
    @_spi(Syscall)
    public static func read(
        fd: Int32,
        buffers: [Segment]
    ) throws(Kernel.IO.Read.Error) -> Int {
        let iovecs = buffers.map { $0.cValue }
        let result = unsafe iovecs.withUnsafeBufferPointer { buf in
            unsafe readv(fd, buf.baseAddress!, Int32(buf.count))
        }

        guard result >= 0 else {
            throw Kernel.IO.Read.Error.current()
        }

        return result
    }
}

// MARK: - Gather Write (raw @_spi(Syscall))

extension ISO_9945.Kernel.IO.Vector {
    /// Writes data from multiple buffers to a raw file descriptor (gather write).
    ///
    /// Spec-literal raw `writev(2)`. Atomically writes from a sequence of
    /// buffers in order; the kernel writes each buffer completely before moving
    /// to the next. The typed L2 convenience
    /// (`ISO_9945.Kernel.IO.Vector.write(_:buffers:)` taking
    /// `borrowing Kernel.Descriptor`) delegates to this raw SPI internally.
    ///
    /// - Parameters:
    ///   - fd: The raw file descriptor to write to.
    ///   - buffers: Array of ``Segment`` values describing send buffers.
    /// - Returns: Total number of bytes written across all buffers.
    /// - Throws: `Kernel.IO.Write.Error` on failure.
    @_spi(Syscall)
    public static func write(
        fd: Int32,
        buffers: [Segment]
    ) throws(Kernel.IO.Write.Error) -> Int {
        let iovecs = buffers.map { $0.cValue }
        let result = unsafe iovecs.withUnsafeBufferPointer { buf in
            unsafe writev(fd, buf.baseAddress!, Int32(buf.count))
        }

        guard result >= 0 else {
            throw Kernel.IO.Write.Error.current()
        }

        return result
    }
}

// MARK: - Typed Convenience

extension ISO_9945.Kernel.IO.Vector {
    /// Reads data from a file descriptor into multiple buffers (scatter read).
    ///
    /// Typed L2 form. Delegates to the raw `read(fd:buffers:)` SPI via
    /// `descriptor._rawValue` after a fast-fail validity check.
    ///
    /// ## Usage
    ///
    /// Scatter read is useful for protocol parsing where header and body
    /// are separate buffers, or when reading into non-contiguous memory.
    ///
    /// - Parameters:
    ///   - descriptor: The file descriptor to read from.
    ///   - buffers: Array of ``Segment`` values describing receive buffers.
    /// - Returns: Total number of bytes read across all buffers.
    /// - Throws: `Kernel.IO.Read.Error` on failure.
    public static func read(
        _ descriptor: borrowing Kernel.Descriptor,
        buffers: [Segment]
    ) throws(Kernel.IO.Read.Error) -> Int {
        guard descriptor.isValid else {
            throw .handle(.invalid)
        }
        return try unsafe read(fd: descriptor._rawValue, buffers: buffers)
    }

    /// Writes data from multiple buffers to a file descriptor (gather write).
    ///
    /// Typed L2 form. Delegates to the raw `write(fd:buffers:)` SPI via
    /// `descriptor._rawValue` after a fast-fail validity check.
    ///
    /// ## Usage
    ///
    /// Gather write avoids copying header + body into a contiguous buffer
    /// before writing. Critical for high-throughput network protocols.
    ///
    /// - Parameters:
    ///   - descriptor: The file descriptor to write to.
    ///   - buffers: Array of ``Segment`` values describing send buffers.
    /// - Returns: Total number of bytes written across all buffers.
    /// - Throws: `Kernel.IO.Write.Error` on failure.
    public static func write(
        _ descriptor: borrowing Kernel.Descriptor,
        buffers: [Segment]
    ) throws(Kernel.IO.Write.Error) -> Int {
        guard descriptor.isValid else {
            throw .handle(.invalid)
        }
        return try unsafe write(fd: descriptor._rawValue, buffers: buffers)
    }
}
