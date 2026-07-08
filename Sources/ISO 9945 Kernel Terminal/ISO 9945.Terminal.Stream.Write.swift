// ===----------------------------------------------------------------------===//
//
// This source file is part of the swift-iso-9945 open source project
//
// Copyright (c) 2024-2026 Coen ten Thije Boonkkamp and the swift-iso-9945 project authors
// Licensed under Apache License v2.0
//
// See LICENSE for license information
//
// ===----------------------------------------------------------------------===//

/// POSIX implementation of Terminal stream write operations.

#if !os(Windows)

    extension Terminal.Stream.Write {
        /// Write bytes to this terminal stream.
        ///
        /// Composes `ISO_9945.Kernel.IO.Write.write(_:Terminal.Stream, from:)` with
        /// a partial-write + EINTR-retry loop. Returns only when every byte has
        /// been written, or throws if the underlying syscall reports a non-EINTR
        /// error.
        ///
        /// Materializes the input sequence into contiguous storage before the
        /// syscall. Callers with already-contiguous bytes (e.g., `ContiguousArray`,
        /// `String.UTF8View`) pay only a single backing copy; callers with
        /// non-contiguous sequences (e.g., a lazy filter) pay the materialization.
        ///
        /// - Parameter bytes: The bytes to write.
        /// - Returns: Total number of bytes written (equals `bytes.count` on
        ///   success; may be less on partial completion before a non-EINTR error).
        /// - Throws: `ISO_9945.Kernel.IO.Write.Error` on a non-EINTR failure.
        @discardableResult
        public func callAsFunction(
            _ bytes: some Swift.Sequence<Byte>
        ) throws(ISO_9945.Kernel.IO.Write.Error) -> Int {
            let array = ContiguousArray<Byte>(bytes)
            return try unsafe array.withUnsafeBufferPointer { (buffer: UnsafeBufferPointer<Byte>) throws(ISO_9945.Kernel.IO.Write.Error) -> Int in
                let raw = UnsafeRawBufferPointer(buffer)
                return try unsafe write(raw)
            }
        }

        /// Inner loop: partial-write + EINTR-retry over a contiguous raw buffer.
        private func write(
            _ raw: UnsafeRawBufferPointer
        ) throws(ISO_9945.Kernel.IO.Write.Error) -> Int {
            var written = 0
            while written < raw.count {
                let remaining = unsafe UnsafeRawBufferPointer(rebasing: raw[written..<raw.count])
                do throws(ISO_9945.Kernel.IO.Write.Error) {
                    let n = try unsafe ISO_9945.Kernel.IO.Write.write(stream, from: remaining)
                    written += n
                } catch let error {
                    if error.code.isInterrupted {
                        continue
                    }
                    throw error
                }
            }
            return written
        }
    }

#endif
