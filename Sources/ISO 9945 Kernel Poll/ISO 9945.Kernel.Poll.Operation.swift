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

#if canImport(Darwin)
    internal import Darwin
#elseif canImport(Glibc)
    internal import Glibc
#elseif canImport(Musl)
    internal import Musl
#elseif canImport(Android)
    internal import Android
#else
    #error("ISO_9945.Kernel.Poll: unsupported platform (no Darwin, Glibc, Musl, or Android)")
#endif

// MARK: - Poll Operation

extension ISO_9945.Kernel.Poll {
    /// Waits for events on a set of file descriptors.
    ///
    /// Blocks until at least one descriptor has a requested event, the timeout
    /// expires, or a signal is caught.
    ///
    /// - Parameters:
    ///   - entries: Array of poll entries to monitor. On return, each entry's
    ///     `returned` field reflects the events that occurred.
    ///   - timeout: Maximum time to wait in milliseconds.
    ///     - `-1`: Block indefinitely.
    ///     - `0`: Return immediately (non-blocking poll).
    ///     - `> 0`: Wait up to this many milliseconds.
    /// - Returns: The number of entries with events, or 0 on timeout.
    /// - Throws: `Error_Primitives.Error` on failure.
    ///
    /// ## Common Errors
    ///
    /// - `.interrupted` (EINTR): Signal interrupted the wait.
    /// - `.invalidArgument` (EINVAL): Invalid timeout or nfds exceeds limit.
    ///
    /// ## Usage
    ///
    /// ```swift
    /// var entries = [
    ///     Poll.Entry(serverFd, requested: .input),
    ///     Poll.Entry(clientFd, requested: [.input, .output]),
    /// ]
    /// let ready = try Poll.poll(&entries, timeout: 5000)
    /// for entry in entries where !entry.returned.isEmpty {
    ///     if entry.returned.contains(.input) { /* readable */ }
    ///     if entry.returned.contains(.output) { /* writable */ }
    ///     if entry.returned.contains(.error) { /* error */ }
    /// }
    /// ```
    public static func poll(
        _ entries: inout [Entry],
        timeout: Int32
    ) throws(Error_Primitives.Error) -> Int {
        let count = unsafe entries.withUnsafeMutableBufferPointer { buffer in
            guard let base = buffer.baseAddress else { return Int32(0) }
            return unsafe base.withMemoryRebound(to: pollfd.self, capacity: buffer.count) {
                pollfdPtr in
                unsafe platformPoll(pollfdPtr, nfds_t(buffer.count), timeout)
            }
        }

        guard count >= 0 else {
            throw Error_Primitives.Error.current(operation: "poll")
        }

        return Int(count)
    }
}

private func platformPoll(
    _ fds: UnsafeMutablePointer<pollfd>,
    _ nfds: nfds_t,
    _ timeout: Int32
) -> Int32 {
    #if canImport(Darwin)
        unsafe Darwin.poll(fds, nfds, timeout)
    #elseif canImport(Glibc)
        unsafe Glibc.poll(fds, nfds, timeout)
    #elseif canImport(Musl)
        unsafe Musl.poll(fds, nfds, timeout)
    #elseif canImport(Android)
        unsafe Android.poll(fds, nfds, timeout)
    #else
        #error(
            "ISO_9945.Kernel.Poll.poll: unsupported platform (no Darwin, Glibc, Musl, or Android)"
        )
    #endif
}
