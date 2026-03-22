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

#if canImport(Darwin)
    internal import Darwin
#elseif canImport(Glibc)
    internal import Glibc
    internal import CLinuxShim
#elseif canImport(Musl)
    internal import Musl
#endif

// MARK: - POSIX uname()

extension ISO_9945.Kernel.System {
    /// Operating system identification via POSIX `uname()`.
    ///
    /// Wraps the POSIX `uname()` syscall, extracting `sysname`, `release`,
    /// and `machine` fields from `struct utsname`.
    ///
    /// - Returns: System identification with name, release version, and hardware type.
    public static var name: Kernel.System.Name {
        var buf = utsname()
        unsafe uname(&buf)
        let system = unsafe withUnsafePointer(to: &buf.sysname) {
            unsafe $0.withMemoryRebound(to: CChar.self, capacity: 256) {
                unsafe Swift.String(cString: $0)
            }
        }
        let release = unsafe withUnsafePointer(to: &buf.release) {
            unsafe $0.withMemoryRebound(to: CChar.self, capacity: 256) {
                unsafe Swift.String(cString: $0)
            }
        }
        let machine = unsafe withUnsafePointer(to: &buf.machine) {
            unsafe $0.withMemoryRebound(to: CChar.self, capacity: 256) {
                unsafe Swift.String(cString: $0)
            }
        }
        return Kernel.System.Name(system: system, release: release, machine: machine)
    }
}
