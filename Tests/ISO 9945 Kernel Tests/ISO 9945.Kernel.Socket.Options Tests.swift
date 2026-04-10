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
import ISO_9945
import Kernel_Primitives_Core
import Kernel_Descriptor_Primitives
import Kernel_Event_Primitives
import Kernel_IO_Primitives
import Kernel_File_Primitives
import Kernel_Path_Primitives
import Kernel_Environment_Primitives
import Kernel_Process_Primitives
import Kernel_Thread_Primitives
import Kernel_Error_Primitives

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
        @Test("Options type exists")
        func typeExists() {
            let _: Kernel.Socket.Options.Type = Kernel.Socket.Options.self
        }

        @Test("Options from rawValue")
        func fromRawValue() {
            let flags = Kernel.Socket.Options(rawValue: O_NONBLOCK)
            #expect(flags.rawValue == O_NONBLOCK)
        }
    }

    // MARK: - Flag Constants Tests

    extension Kernel.Socket.Options.Test.Unit {
        @Test("nonBlock flag")
        func nonBlockFlag() {
            let flags = Kernel.Socket.Options.nonBlock
            #expect(flags.rawValue == O_NONBLOCK)
        }

        @Test("closeOnExec flag")
        func closeOnExecFlag() {
            let flags = Kernel.Socket.Options.closeOnExec
            #expect(flags.rawValue == O_CLOEXEC)
        }

        @Test("none flag is empty")
        func noneFlag() {
            let flags = Kernel.Socket.Options.none
            #expect(flags.isEmpty)
            #expect(flags.rawValue == 0)
        }

        @Test("asyncDefault combines nonBlock and closeOnExec")
        func asyncDefaultFlag() {
            let flags = Kernel.Socket.Options.asyncDefault
            #expect(flags.contains(.nonBlock))
            #expect(flags.contains(.closeOnExec))
        }
    }

    // MARK: - OptionSet Tests

    extension Kernel.Socket.Options.Test.Unit {
        @Test("Options can be combined with array literal")
        func flagCombination() {
            let combined: Kernel.Socket.Options = [.nonBlock, .closeOnExec]
            #expect(combined.contains(.nonBlock))
            #expect(combined.contains(.closeOnExec))
        }

        @Test("Options contains check")
        func containsCheck() {
            let flags: Kernel.Socket.Options = [.nonBlock, .closeOnExec]
            #expect(flags.contains(.nonBlock))
            #expect(flags.contains(.closeOnExec))
        }

        @Test("Options array literal initialization")
        func arrayLiteralInit() {
            let flags: Kernel.Socket.Options = [.nonBlock, .closeOnExec]
            #expect(flags == .asyncDefault)
        }
    }

    // MARK: - Conformance Tests

    extension Kernel.Socket.Options.Test.Unit {
        @Test("Options is Sendable")
        func isSendable() {
            let value: any Sendable = Kernel.Socket.Options.none
            #expect(value is Kernel.Socket.Options)
        }

        @Test("Options is Equatable")
        func isEquatable() {
            let a = Kernel.Socket.Options.nonBlock
            let b = Kernel.Socket.Options.nonBlock
            let c = Kernel.Socket.Options.closeOnExec
            #expect(a == b)
            #expect(a != c)
        }
    }

    // MARK: - Edge Cases

    extension Kernel.Socket.Options.Test.EdgeCase {
        @Test("Empty flags is none")
        func emptyIsNone() {
            let empty: Kernel.Socket.Options = []
            #expect(empty == .none)
        }

        @Test("Options rawValue roundtrip")
        func rawValueRoundtrip() {
            let original: Kernel.Socket.Options = [.nonBlock, .closeOnExec]
            let roundtrip = Kernel.Socket.Options(rawValue: original.rawValue)
            #expect(roundtrip == original)
        }
    }

