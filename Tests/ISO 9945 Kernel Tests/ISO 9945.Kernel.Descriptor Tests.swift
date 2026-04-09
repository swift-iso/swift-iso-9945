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

// Tests use Apple native Testing framework
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

@testable import ISO_9945_Kernel

extension Kernel.Descriptor {
    @Suite
    struct Test {
        @Suite struct Unit {}
        @Suite struct EdgeCase {}
    }
}

// MARK: - Unit Tests

// Kernel.Descriptor is ~Copyable, Sendable per [MEM-COPY-001] — resource types
// are not Equatable/Hashable/Copyable. Test assertions use fileDescriptor raw
// values for comparison and extract bool results to locals before #expect,
// because swift-testing's #expect macro captures expressions (__checkPropertyAccess,
// __checkBinaryOperation) which require Copyable.

extension Kernel.Descriptor.Test.Unit {
    @Test("invalid descriptor has correct raw value on POSIX")
    func invalidDescriptorValue() {
        let invalidFd = Kernel.Descriptor.invalid.fileDescriptor
        #expect(invalidFd == -1)
    }

    @Test("isValid returns false for invalid descriptor")
    func isValidFalseForInvalid() {
        let isValid = Kernel.Descriptor.invalid.isValid
        #expect(!isValid)
    }

    @Test("isValid returns true for valid descriptor")
    func isValidTrueForValid() throws {
        // Open a real file so we have a definitively valid fd without
        // constructing Descriptor instances from well-known raw values
        // (e.g., 0/1/2 for stdin/stdout/stderr). Constructing a
        // ~Copyable Descriptor from such a raw value would cause its
        // deinit to close() the test process's own standard streams.
        let path = KernelIOTest.makeTempPath(prefix: "valid-fd-test")
        defer { KernelIOTest.cleanup(path: path) }
        let fd = try KernelIOTest.open(at: path)
        let fdIsValid = fd.isValid
        #expect(fdIsValid)
    }

    @Test("negative descriptors are invalid on POSIX")
    func negativeDescriptorsInvalid() {
        let minusOne = Kernel.Descriptor(_rawValue: -1).isValid
        let minusHundred = Kernel.Descriptor(_rawValue: -100).isValid
        let intMin = Kernel.Descriptor(_rawValue: Int32.min).isValid
        #expect(!minusOne)
        #expect(!minusHundred)
        #expect(!intMin)
    }
}
