// ===----------------------------------------------------------------------===//
//
// This source file is part of the swift-kernel open source project
//
// Copyright (c) 2024 Coen ten Thije Boonkkamp and the swift-kernel project authors
// Licensed under Apache License v2.0
//
// See LICENSE for license information
//
// ===----------------------------------------------------------------------===//


    #if canImport(Darwin)
        import Darwin
    #elseif canImport(Glibc)
        import Glibc
    #elseif canImport(Musl)
        import Musl
    #endif

    // Tests use Apple native Testing framework
import Testing
import ISO_9945_Kernel_Test_Support
import ISO_9945_Kernel
import Kernel_Primitives_Core
import Kernel_Descriptor_Primitives
import Kernel_Event_Primitives
import Kernel_IO_Primitives
import Kernel_File_Primitives
import Kernel_Path_Primitives
import Kernel_Environment_Primitives
import Kernel_Process_Primitives
import Kernel_Thread_Primitives
import Error_Primitives

    @testable import ISO_9945_Kernel

    extension Kernel.Socket.Options {
        @Suite
    struct Test {
        @Suite struct Unit {}
        @Suite struct EdgeCase {}
    }
    }

    // MARK: - Unit Tests

    extension Kernel.Socket.Options.Test.Unit {
        @Test
        func `Options type exists`() {
            let _: Kernel.Socket.Options.Type = Kernel.Socket.Options.self
        }

        @Test
        func `Options from rawValue`() {
            let flags = Kernel.Socket.Options(rawValue: O_NONBLOCK)
            #expect(flags.rawValue == O_NONBLOCK)
        }
    }

    // MARK: - Flag Constants Tests

    extension Kernel.Socket.Options.Test.Unit {
        @Test
        func `nonBlock flag`() {
            let flags = Kernel.Socket.Options.nonBlock
            #expect(flags.rawValue == O_NONBLOCK)
        }

        @Test
        func `closeOnExec flag`() {
            let flags = Kernel.Socket.Options.closeOnExec
            #expect(flags.rawValue == O_CLOEXEC)
        }

        @Test
        func `none flag is empty`() {
            let flags = Kernel.Socket.Options.none
            #expect(flags.isEmpty)
            #expect(flags.rawValue == 0)
        }

        @Test
        func `asyncDefault combines nonBlock and closeOnExec`() {
            let flags = Kernel.Socket.Options.asyncDefault
            #expect(flags.contains(.nonBlock))
            #expect(flags.contains(.closeOnExec))
        }
    }

    // MARK: - OptionSet Tests

    extension Kernel.Socket.Options.Test.Unit {
        @Test
        func `Options can be combined with array literal`() {
            let combined: Kernel.Socket.Options = [.nonBlock, .closeOnExec]
            #expect(combined.contains(.nonBlock))
            #expect(combined.contains(.closeOnExec))
        }

        @Test
        func `Options contains check`() {
            let flags: Kernel.Socket.Options = [.nonBlock, .closeOnExec]
            #expect(flags.contains(.nonBlock))
            #expect(flags.contains(.closeOnExec))
        }

        @Test
        func `Options array literal initialization`() {
            let flags: Kernel.Socket.Options = [.nonBlock, .closeOnExec]
            #expect(flags == .asyncDefault)
        }
    }

    // MARK: - Conformance Tests

    extension Kernel.Socket.Options.Test.Unit {
        @Test
        func `Options is Sendable`() {
            let value: any Sendable = Kernel.Socket.Options.none
            #expect(value is Kernel.Socket.Options)
        }

        @Test
        func `Options is Equatable`() {
            let a = Kernel.Socket.Options.nonBlock
            let b = Kernel.Socket.Options.nonBlock
            let c = Kernel.Socket.Options.closeOnExec
            #expect(a == b)
            #expect(a != c)
        }
    }

    // MARK: - Edge Cases

    extension Kernel.Socket.Options.Test.EdgeCase {
        @Test
        func `Empty flags is none`() {
            let empty: Kernel.Socket.Options = []
            #expect(empty == .none)
        }

        @Test
        func `Options rawValue roundtrip`() {
            let original: Kernel.Socket.Options = [.nonBlock, .closeOnExec]
            let roundtrip = Kernel.Socket.Options(rawValue: original.rawValue)
            #expect(roundtrip == original)
        }
    }

