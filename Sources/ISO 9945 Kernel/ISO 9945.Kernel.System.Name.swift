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

@_spi(Syscall) public import Kernel_Primitives_Core
@_spi(Syscall) public import Kernel_Descriptor_Primitives
@_spi(Syscall) public import Kernel_Error_Primitives
@_spi(Syscall) public import Kernel_File_Primitives
@_spi(Syscall) public import Kernel_IO_Primitives
@_spi(Syscall) public import Kernel_Socket_Primitives
@_spi(Syscall) public import Kernel_Memory_Primitives
@_spi(Syscall) public import Kernel_Process_Primitives
@_spi(Syscall) public import Kernel_Permission_Primitives
@_spi(Syscall) public import Kernel_Path_Primitives
@_spi(Syscall) public import Kernel_Thread_Primitives
@_spi(Syscall) public import Kernel_System_Primitives
@_spi(Syscall) public import Kernel_Time_Primitives
@_spi(Syscall) public import Kernel_Clock_Primitives
@_spi(Syscall) public import Kernel_Random_Primitives
@_spi(Syscall) public import Kernel_Environment_Primitives
@_spi(Syscall) public import Kernel_Syscall_Primitives
@_spi(Syscall) public import Kernel_Terminal_Primitives
public import ISO_9945

#if canImport(Darwin)
    internal import Darwin
#elseif canImport(Glibc)
    internal import Glibc
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
