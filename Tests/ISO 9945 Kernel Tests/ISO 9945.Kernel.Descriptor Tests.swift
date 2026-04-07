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
@_spi(Syscall) import Kernel_Primitives

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
    func isValidTrueForValid() {
        // Standard input (0), stdout (1), stderr (2) are always valid
        let stdinValid = Kernel.Descriptor(_rawValue: 0).isValid
        let stdoutValid = Kernel.Descriptor(_rawValue: 1).isValid
        let stderrValid = Kernel.Descriptor(_rawValue: 2).isValid
        #expect(stdinValid)
        #expect(stdoutValid)
        #expect(stderrValid)
    }

    @Test("internal raw roundtrip preserves value")
    func internalRawRoundtrip() {
        let original = Kernel.Descriptor(_rawValue: 42).fileDescriptor
        let reconstructed = Kernel.Descriptor(_rawValue: 42).fileDescriptor
        #expect(original == reconstructed)
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
