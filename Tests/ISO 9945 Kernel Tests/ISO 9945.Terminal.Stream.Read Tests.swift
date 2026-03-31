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
@_spi(Syscall) import Kernel_Primitives
import Terminal_Primitives

@testable import ISO_9945_Kernel

extension Terminal.Stream.Read {
    @Suite
    struct Test {
        @Suite(.serialized) struct Integration {}
    }
}

// MARK: - Integration

extension Terminal.Stream.Read.Test.Integration {
    @Test
    func `Read bytes from pipe via stdin redirect`() throws {
        let pipe = try Kernel.Event.Test.makePipe()

        let stdinDescriptor = Kernel.Descriptor(_rawValue: Terminal.Stream.stdin.rawValue)
        let savedStdin = try ISO_9945.Kernel.Descriptor.Duplicate.duplicate(stdinDescriptor)
        defer {
            try? ISO_9945.Kernel.Descriptor.Duplicate.duplicate(savedStdin, to: stdinDescriptor)
        }

        try ISO_9945.Kernel.Descriptor.Duplicate.duplicate(pipe.read, to: stdinDescriptor)

        // Write "Hello" to pipe
        let testData: [UInt8] = [0x48, 0x65, 0x6C, 0x6C, 0x6F]
        for byte in testData {
            Kernel.Event.Test.writeByte(pipe.write, value: byte)
        }

        var buffer = [UInt8](repeating: 0, count: 64)
        let bytesRead = try buffer.withUnsafeMutableBytes { ptr in
            try Terminal.Stream.stdin.read(into: ptr)
        }

        #expect(bytesRead == 5)
        #expect(Array(buffer.prefix(5)) == testData)
    }

    @Test
    func `Read returns 0 on EOF when write end closed`() throws {
        let pipe = try Kernel.Event.Test.makePipe()

        let stdinDescriptor = Kernel.Descriptor(_rawValue: Terminal.Stream.stdin.rawValue)
        let savedStdin = try ISO_9945.Kernel.Descriptor.Duplicate.duplicate(stdinDescriptor)
        defer {
            try? ISO_9945.Kernel.Descriptor.Duplicate.duplicate(savedStdin, to: stdinDescriptor)
        }

        try ISO_9945.Kernel.Descriptor.Duplicate.duplicate(pipe.read, to: stdinDescriptor)

        // Close write end to signal EOF
        try? Kernel.Close.close(pipe.write)

        var buffer = [UInt8](repeating: 0, count: 64)
        let bytesRead = try buffer.withUnsafeMutableBytes { ptr in
            try Terminal.Stream.stdin.read(into: ptr)
        }

        #expect(bytesRead == 0)
    }

    @Test
    func `Read escape sequence bytes from pipe`() throws {
        let pipe = try Kernel.Event.Test.makePipe()

        let stdinDescriptor = Kernel.Descriptor(_rawValue: Terminal.Stream.stdin.rawValue)
        let savedStdin = try ISO_9945.Kernel.Descriptor.Duplicate.duplicate(stdinDescriptor)
        defer {
            try? ISO_9945.Kernel.Descriptor.Duplicate.duplicate(savedStdin, to: stdinDescriptor)
        }

        try ISO_9945.Kernel.Descriptor.Duplicate.duplicate(pipe.read, to: stdinDescriptor)

        // Write ESC[A (up arrow escape sequence)
        let escapeSequence: [UInt8] = [0x1B, 0x5B, 0x41]
        for byte in escapeSequence {
            Kernel.Event.Test.writeByte(pipe.write, value: byte)
        }

        var buffer = [UInt8](repeating: 0, count: 64)
        let bytesRead = try buffer.withUnsafeMutableBytes { ptr in
            try Terminal.Stream.stdin.read(into: ptr)
        }

        #expect(bytesRead == 3)
        #expect(Array(buffer.prefix(3)) == escapeSequence)
    }

    @Test
    func `Read multiple bytes preserves order`() throws {
        let pipe = try Kernel.Event.Test.makePipe()

        let stdinDescriptor = Kernel.Descriptor(_rawValue: Terminal.Stream.stdin.rawValue)
        let savedStdin = try ISO_9945.Kernel.Descriptor.Duplicate.duplicate(stdinDescriptor)
        defer {
            try? ISO_9945.Kernel.Descriptor.Duplicate.duplicate(savedStdin, to: stdinDescriptor)
        }

        try ISO_9945.Kernel.Descriptor.Duplicate.duplicate(pipe.read, to: stdinDescriptor)

        // Write bytes in specific order
        let ordered: [UInt8] = [0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08]
        for byte in ordered {
            Kernel.Event.Test.writeByte(pipe.write, value: byte)
        }

        var buffer = [UInt8](repeating: 0, count: 64)
        let bytesRead = try buffer.withUnsafeMutableBytes { ptr in
            try Terminal.Stream.stdin.read(into: ptr)
        }

        #expect(bytesRead == 8)
        #expect(Array(buffer.prefix(8)) == ordered)
    }
}
