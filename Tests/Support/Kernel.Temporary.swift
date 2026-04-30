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

/// Test support for cross-platform temporary file paths.

public import Kernel_Primitives_Core
public import Kernel_Event_Primitives
public import Kernel_File_Primitives
public import Path_Primitives
public import Kernel_Process_Primitives
public import Error_Primitives
public import String_Primitives
public import ISO_9945_Kernel
public import ISO_9945_Kernel

extension Kernel {
    /// Namespace for temporary path operations in tests.
    public enum Temporary {}
}

extension Kernel.Temporary {
    /// Returns the system temp directory path.
    ///
    /// Uses platform-appropriate environment variables:
    /// - Unix: `TMPDIR`, falling back to "/tmp"
    /// - Windows: `TEMP` or `TMP`, falling back to "C:\Temp"
    public static var directory: Swift.String {
        #if os(Windows)
            if let temp = unsafe ISO_9945.Kernel.Environment.get("TEMP") {
                return unsafe temp.withUnsafePointer { Swift.String(cString: $0) }
            }
            if let tmp = unsafe ISO_9945.Kernel.Environment.get("TMP") {
                return unsafe tmp.withUnsafePointer { Swift.String(cString: $0) }
            }
            return "C:\\Temp"
        #else
            if let tmpdir = unsafe ISO_9945.Kernel.Environment.get("TMPDIR") {
                return unsafe tmpdir.withUnsafePointer { Swift.String(cString: $0) }
            }
            return "/tmp"
        #endif
    }

    /// Generates a unique temporary file path.
    ///
    /// - Parameter prefix: Prefix for the filename (e.g., "kernel-test").
    /// - Returns: A unique path string in the system temp directory.
    public static func filePath(prefix: Swift.String) -> Swift.String {
        let pid = Int(ISO_9945.Kernel.Process.ID.current.rawValue)
        let random = Int.random(in: 0..<Int.max)
        let name = "\(prefix)-\(pid)-\(random)"

        #if os(Windows)
            return directory + "\\" + name
        #else
            return directory + "/" + name
        #endif
    }
}
