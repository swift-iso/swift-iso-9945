// ===----------------------------------------------------------------------===//
//
// This source file is part of the swift-posix open source project
//
// Copyright (c) 2024-2025 Coen ten Thije Boonkkamp and the swift-posix project authors
// Licensed under Apache License v2.0
//
// See LICENSE for license information
//
// ===----------------------------------------------------------------------===//

@_spi(Syscall) import Kernel_Descriptor_Primitives

#if canImport(Darwin)
    internal import Darwin
    internal import CPOSIXProcessShim
#elseif canImport(Glibc)
    internal import Glibc
    internal import CPOSIXProcessShim
#elseif canImport(Musl)
    internal import Musl
    internal import CPOSIXProcessShim
#endif

extension ISO_9945.Kernel.Process {
    /// Execute operations namespace.
    public enum Execute {}
}

// MARK: - Execute Operation

extension ISO_9945.Kernel.Process.Execute {
    /// Replaces current process image with a new program.
    ///
    /// - Parameters:
    ///   - path: Path to the executable (null-terminated C string).
    ///   - argv: Argument vector (null-terminated array of C strings).
    ///   - envp: Environment vector (null-terminated array of C strings).
    /// - Throws: `ISO_9945.Kernel.Process.Error.execute` (only returns on failure).
    ///
    /// ## Important
    ///
    /// This function does NOT return on success. The process image is replaced.
    ///
    /// ## Common Errors
    ///
    /// - ENOENT: File not found.
    /// - EACCES: Permission denied.
    /// - ENOEXEC: Invalid executable format.
    /// - ENOMEM: Insufficient memory.
    /// - E2BIG: Argument list too long.
    ///
    /// ## Memory Requirements
    ///
    /// - `argv` and `envp` MUST be null-terminated arrays of pointers.
    /// - Each element points to a null-terminated C string.
    /// - Caller owns all memory until the call completes.
    /// - On success, the process image is replaced (memory is irrelevant).
    /// - On failure, memory ownership returns to caller.
    ///
    /// ## Usage
    ///
    /// ```swift
    /// switch try ISO_9945.Kernel.Process.Fork.fork() {
    /// case .child:
    ///     "/bin/ls".withCString { path in
    ///         let argv: [UnsafePointer<CChar>?] = [path, nil]
    ///         let envp: [UnsafePointer<CChar>?] = [nil]
    ///         argv.withUnsafeBufferPointer { argvBuf in
    ///             envp.withUnsafeBufferPointer { envpBuf in
    ///                 try? ISO_9945.Kernel.Process.Execute.execve(
    ///                     path: path,
    ///                     argv: argvBuf.baseAddress!,
    ///                     envp: envpBuf.baseAddress!
    ///                 )
    ///             }
    ///         }
    ///     }
    ///     ISO_9945.Kernel.Process.Exit.now(127) // execute failed
    /// case .parent(let child):
    ///     let result = try ISO_9945.Kernel.Process.Wait.wait(.process(child))
    /// }
    /// ```
    @unsafe
    public static func execve(
        path: UnsafePointer<CChar>,
        argv: UnsafePointer<UnsafePointer<CChar>?>,
        envp: UnsafePointer<UnsafePointer<CChar>?>
    ) throws(ISO_9945.Kernel.Process.Error) {
        // execve only returns on failure
        #if canImport(Darwin)
            _ = unsafe swift_execve(path, argv, envp)
        #elseif canImport(Glibc)
            _ = unsafe swift_execve(path, argv, envp)
        #elseif canImport(Musl)
            _ = unsafe Musl.execve(path, argv, envp)
        #endif
        throw .execute(ISO_9945.Kernel.Error.captureErrno())
    }
}
