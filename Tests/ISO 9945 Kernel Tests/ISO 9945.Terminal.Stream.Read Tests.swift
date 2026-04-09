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

import Testing
import ISO_9945_Kernel_Test_Support
import ISO_9945
@_spi(Syscall) import Kernel_Primitives_Core
@_spi(Syscall) import Kernel_Descriptor_Primitives
@_spi(Syscall) import Kernel_Event_Primitives
@_spi(Syscall) import Kernel_IO_Primitives
@_spi(Syscall) import Kernel_File_Primitives
@_spi(Syscall) import Kernel_Path_Primitives
@_spi(Syscall) import Kernel_Environment_Primitives
@_spi(Syscall) import Kernel_Process_Primitives
@_spi(Syscall) import Kernel_Thread_Primitives
@_spi(Syscall) import Kernel_Error_Primitives
import Terminal_Primitives

@testable import ISO_9945_Kernel

extension Terminal.Stream.Read {
    @Suite
    struct Test {
        @Suite struct Integration {}
    }
}

// MARK: - Integration
//
// The original tests in this file stubbed stdin redirection by
// constructing `Kernel.Descriptor(_rawValue: Terminal.Stream.stdin.rawValue)`
// — claiming ownership of fd 0. When the ~Copyable Descriptor went out
// of scope, its deinit called close(0), which closed the test process's
// own standard input. swift-testing (and any subsequent test) would then
// fail because its I/O was broken.
//
// Proper stdin redirection testing requires either:
//   1. A non-owning "borrowed descriptor" API for well-known fds, or
//   2. A spawned child process whose stdin is the pipe under test, with
//      the parent reading results back from the child.
//
// Neither is in place yet. The tests below are disabled until a correct
// mechanism for testing Terminal.Stream.Read.read exists.

extension Terminal.Stream.Read.Test.Integration {
    @Test(.disabled("pending: stdin redirection needs non-owning descriptor API or child-process harness"))
    func `Read bytes from pipe via stdin redirect`() throws {
        // Placeholder — re-enable when a non-destructive stdin redirection
        // mechanism exists.
    }

    @Test(.disabled("pending: Pipe API does not expose owned write-end for individual close"))
    func `Read returns 0 on EOF when write end closed`() throws {
        // Placeholder — re-enable when Pipe.Descriptors provides a consuming
        // accessor for the write end.
    }

    @Test(.disabled("pending: stdin redirection needs non-owning descriptor API or child-process harness"))
    func `Read escape sequence bytes from pipe`() throws {
        // Placeholder.
    }

    @Test(.disabled("pending: stdin redirection needs non-owning descriptor API or child-process harness"))
    func `Read multiple bytes preserves order`() throws {
        // Placeholder.
    }
}
