// ===----------------------------------------------------------------------===//
//
// This source file is part of the swift-iso-9945 open source project
//
// Copyright (c) 2024-2025 Coen ten Thije Boonkkamp and the swift-iso-9945 project authors
// Licensed under Apache License v2.0
//
// See LICENSE for license information
//
// ===----------------------------------------------------------------------===//

@_spi(Syscall) public import Kernel_Primitives
public import ISO_9945
internal import ISO_9945_ABI

#if canImport(Darwin)
    internal import Darwin
#elseif canImport(Glibc)
    internal import Glibc
#elseif canImport(Musl)
    internal import Musl
#endif

// MARK: - POSIX directory operations

extension ISO_9945.Kernel.Directory {
    public typealias Entry = Kernel.Directory.Entry
    public typealias Error = Kernel.Directory.Error

    /// A directory stream for iterating over directory entries.
    @safe
    public final class Stream: @unchecked Sendable {
        private var dir: UnsafeMutablePointer<DIR>?

        fileprivate init(dir: UnsafeMutablePointer<DIR>) {
            unsafe self.dir = dir
        }

        deinit {
            if let d = unsafe dir {
                unsafe closedir(d)
            }
        }

        /// Closes the directory stream.
        public func close() {
            if let d = unsafe dir {
                unsafe closedir(d)
                unsafe self.dir = nil
            }
        }

        /// Returns the next entry, or nil if at end of directory.
        public func next() throws(Error) -> Entry? {
            guard let d = unsafe dir else {
                return nil
            }

            // Reset errno before calling readdir
            errno = 0
            guard let entry = unsafe readdir(d) else {
                // Check if this was an error or end of directory
                if errno != 0 {
                    throw Error.currentRead()
                }
                return nil
            }

            // Extract raw bytes from d_name tuple
            let rawName: [UInt8] = unsafe withUnsafePointer(to: entry.pointee.d_name) { ptr in
                let bufferSize = MemoryLayout.size(ofValue: unsafe entry.pointee.d_name)
                return unsafe ptr.withMemoryRebound(to: UInt8.self, capacity: bufferSize) { bytes in
                    var length = 0
                    while length < bufferSize && (unsafe bytes[length]) != 0 {
                        length += 1
                    }
                    return unsafe Array(UnsafeBufferPointer(start: bytes, count: length))
                }
            }

            // Map d_type to file type
            let type: Kernel.File.Stats.Kind? = {
                switch Int32(unsafe entry.pointee.d_type) {
                case DT_REG: return .regular
                case DT_DIR: return .directory
                case DT_LNK: return .link(.symbolic)
                case DT_CHR: return .device(.character)
                case DT_BLK: return .device(.block)
                case DT_FIFO: return .fifo
                case DT_SOCK: return .socket
                default: return nil // DT_UNKNOWN
                }
            }()

            return Entry(
                rawName: rawName,
                inode: Kernel.Inode(UInt64(unsafe entry.pointee.d_ino)),
                type: type
            )
        }
    }

    /// Opens a directory for iteration.
    ///
    /// - Parameter path: The path to the directory.
    /// - Returns: A directory stream for iteration.
    /// - Throws: `Kernel.Directory.Error` on failure.
    @unsafe
    public static func open(at path: UnsafePointer<Kernel.Path.Char>) throws(Error) -> Stream {
        let cPath = unsafe UnsafePointer<CChar>(path)

        guard let dir = unsafe opendir(cPath) else {
            throw Error.currentOpen()
        }
        return Stream(dir: unsafe dir)
    }

    /// Opens a directory for iteration using a `Kernel.Path`.
    ///
    /// This is the preferred entry point. The pointer-based overload exists
    /// for cases where you already have a raw pointer.
    ///
    /// - Parameter path: The path to the directory.
    /// - Returns: A directory stream for iteration.
    /// - Throws: `Kernel.Directory.Error` on failure.
    public static func open(at path: borrowing Kernel.Path.View) throws(Error) -> Stream {
        try unsafe path.withUnsafePointer { (ptr: UnsafePointer<Kernel.Path.Char>) throws(Error) in
            try open(at: ptr)
        }
    }
}

// MARK: - Error helpers

extension ISO_9945.Kernel.Directory.Error {
    /// Creates an error from the current errno for open operations.
    internal static func currentOpen() -> Self {
        let code = Kernel.Error.Code.current()
        switch code {
        case .ENOENT:
            return .notFound
        case .EACCES:
            return .permission
        case .ENOTDIR:
            return .notDirectory
        case .EMFILE, .ENFILE:
            return .tooManyOpenFiles
        default:
            return .platform(Kernel.Error(code: code))
        }
    }

    /// Creates an error from the current errno for read operations.
    internal static func currentRead() -> Self {
        let code = Kernel.Error.Code.current()
        switch code {
        case .EIO:
            return .io
        default:
            return .platform(Kernel.Error(code: code))
        }
    }
}
