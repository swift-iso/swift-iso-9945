@_spi(Syscall) import Kernel_Descriptor_Primitives
@_spi(Syscall) import Kernel_File_Primitives

#if canImport(Darwin)
    internal import Darwin
#elseif canImport(Glibc)
    internal import Glibc
#elseif canImport(Musl)
    internal import Musl
#endif

extension ISO_9945.Kernel.File {
    /// File truncation namespace.
    public enum Truncate {}
}

// MARK: - POSIX ftruncate() syscall (raw @_spi(Syscall))

extension ISO_9945.Kernel.File.Truncate {
    /// Truncates a file to a specified length via raw file descriptor.
    ///
    /// Spec-literal raw `ftruncate(2)`. If the file is larger than `length`,
    /// the extra data is lost. If the file is shorter than `length`, it is
    /// extended with zero bytes. The typed L2 convenience
    /// (`ISO_9945.Kernel.File.Truncate.truncate(_:to:)` taking
    /// `borrowing Kernel.Descriptor`) delegates to this raw SPI internally.
    ///
    /// - Parameters:
    ///   - fd: The raw file descriptor (must be open for writing).
    ///   - length: The new file size in bytes.
    /// - Throws: `Error_Primitives.Error` on failure.
    ///
    /// ## Common Errors
    ///
    /// - `.invalidArgument` (EINVAL): Length is negative or too large.
    /// - `.accessDenied` (EACCES): File is not open for writing.
    @_spi(Syscall)
    public static func truncate(
        fd: Int32,
        to length: Kernel.File.Size
    ) throws(Error_Primitives.Error) {
        let rc = unsafe ftruncate(fd, off_t(length.rawValue))

        guard rc == 0 else {
            throw Error_Primitives.Error.current(operation: "ftruncate")
        }
    }
}

// MARK: - Typed Convenience + path overloads

extension ISO_9945.Kernel.File.Truncate {
    /// Truncates a file to a specified length via file descriptor.
    ///
    /// Typed L2 form. Delegates to the raw `truncate(fd:to:)` SPI via
    /// `descriptor._rawValue`.
    ///
    /// If the file is larger than `length`, the extra data is lost.
    /// If the file is shorter than `length`, it is extended with zero bytes.
    ///
    /// - Parameters:
    ///   - descriptor: The file descriptor (must be open for writing).
    ///   - length: The new file size in bytes.
    /// - Throws: `Error_Primitives.Error` on failure.
    public static func truncate(
        _ descriptor: borrowing Kernel.Descriptor,
        to length: Kernel.File.Size
    ) throws(Error_Primitives.Error) {
        try unsafe truncate(fd: descriptor._rawValue, to: length)
    }

    /// Truncates a file to a specified length via path.
    ///
    /// - Parameters:
    ///   - path: The file path.
    ///   - length: The new file size in bytes.
    /// - Throws: `Error_Primitives.Error` on failure.
    public static func truncate(
        path: UnsafePointer<CChar>,
        to length: Kernel.File.Size
    ) throws(Error_Primitives.Error) {
        let rc = unsafe Darwin_or_Glibc_truncate(path, off_t(length.rawValue))

        guard rc == 0 else {
            throw Error_Primitives.Error.current(operation: "truncate")
        }
    }
}

private func Darwin_or_Glibc_truncate(_ path: UnsafePointer<CChar>, _ length: off_t) -> Int32 {
    #if canImport(Darwin)
        unsafe Darwin.truncate(path, length)
    #elseif canImport(Glibc)
        unsafe Glibc.truncate(path, length)
    #elseif canImport(Musl)
        unsafe Musl.truncate(path, length)
    #endif
}
