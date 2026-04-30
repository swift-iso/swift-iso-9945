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

/// Lock test helper - holds a file lock for a specified duration.
///
/// This helper is spawned by tests to create true multi-process lock contention,
/// since POSIX advisory locks are per-process (same-process re-locking succeeds).
///
/// ## Usage
///
/// ```
/// iso-9945-lock-helper <path> <milliseconds>
/// ```
///
/// - Opens the file at `path`
/// - Acquires an exclusive lock on the entire file
/// - Prints "LOCKED" to stdout when lock is held
/// - Sleeps for `milliseconds`
/// - Releases lock and exits

#if os(macOS) || os(Linux)

public import Kernel_File_Primitives
public import Path_Primitives
public import Error_Primitives
import ISO_9945_Kernel
@_spi(Syscall) import ISO_9945_Kernel_Lock

@main
struct LockHelper {
    static func main() {
        let args = CommandLine.arguments

        guard args.count >= 3 else {
            print("Usage: iso-9945-lock-helper <path> <milliseconds>")
            ISO_9945.Kernel.Process.Exit.now(1)
        }

        let path = args[1]
        guard let milliseconds = Int(args[2]), milliseconds > 0 else {
            print("Error: milliseconds must be a positive integer")
            ISO_9945.Kernel.Process.Exit.now(1)
        }

        do {
            try Path.scope(path) { kernelPath in
                // Open file for reading/writing (required for exclusive locks)
                let fd = try ISO_9945.Kernel.File.Open.open(
                    path: kernelPath,
                    mode: .readWrite,
                    options: [],
                    permissions: 0
                )

                // Acquire exclusive lock (via raw fd SPI per Path X Phase 1)
                try ISO_9945.Kernel.Lock.lock(fd: fd._rawValue, range: .file, kind: .exclusive)
                defer { try? ISO_9945.Kernel.Lock.unlock(fd: fd._rawValue, range: .file) }

                // Signal that lock is held
                print("LOCKED")

                // Hold lock for specified duration
                System.sleep(.milliseconds(milliseconds))
            }

            print("RELEASED")
            ISO_9945.Kernel.Process.Exit.now(0)
        } catch {
            print("Error: \(error)")
            ISO_9945.Kernel.Process.Exit.now(1)
        }
    }
}

#endif
