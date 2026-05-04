// ===----------------------------------------------------------------------===//
//
// This source file is part of the swift-kernel open source project
//
// Copyright (c) 2024-2025 Coen ten Thije Boonkkamp and the swift-kernel project authors
// Licensed under Apache License v2.0
//
// See LICENSE for license information
//
// ===----------------------------------------------------------------------===//

// Tests use Apple native Testing framework
import Testing
import Tagged_Primitives_Standard_Library_Integration
import ISO_9945_Kernel


extension ISO_9945.Kernel.File.Direct.Error.Syscall {
    @Suite
    struct Test {
        @Suite struct Unit {}
        @Suite struct EdgeCase {}
    }
}

// MARK: - Unit Tests

extension ISO_9945.Kernel.File.Direct.Error.Syscall.Test.Unit {
    @Test
    func `platform case exists`() {
        let syscall = ISO_9945.Kernel.File.Direct.Error.Syscall.platform(code: .posix(1), operation: .open)
        if case .platform = syscall {
            // Expected
        } else {
            Issue.record("Expected .platform case")
        }
    }

    @Test
    func `invalidDescriptor case exists`() {
        let syscall = ISO_9945.Kernel.File.Direct.Error.Syscall.invalidDescriptor(operation: .read)
        if case .invalidDescriptor = syscall {
            // Expected
        } else {
            Issue.record("Expected .invalidDescriptor case")
        }
    }

    @Test
    func `alignmentViolation case exists`() {
        let syscall = ISO_9945.Kernel.File.Direct.Error.Syscall.alignmentViolation(operation: .write)
        if case .alignmentViolation = syscall {
            // Expected
        } else {
            Issue.record("Expected .alignmentViolation case")
        }
    }

    @Test
    func `notSupported case exists`() {
        let syscall = ISO_9945.Kernel.File.Direct.Error.Syscall.notSupported(operation: .open)
        if case .notSupported = syscall {
            // Expected
        } else {
            Issue.record("Expected .notSupported case")
        }
    }
}

// MARK: - Conformance Tests

extension ISO_9945.Kernel.File.Direct.Error.Syscall.Test.Unit {
    @Test
    func `Syscall conforms to Swift.Error`() {
        let syscall: any Swift.Error = ISO_9945.Kernel.File.Direct.Error.Syscall.platform(code: .posix(1), operation: .open)
        #expect(syscall is ISO_9945.Kernel.File.Direct.Error.Syscall)
    }

    @Test
    func `Syscall is Sendable`() {
        let syscall: any Sendable = ISO_9945.Kernel.File.Direct.Error.Syscall.platform(code: .posix(1), operation: .open)
        #expect(syscall is ISO_9945.Kernel.File.Direct.Error.Syscall)
    }

    @Test
    func `Syscall is Equatable`() {
        let a = ISO_9945.Kernel.File.Direct.Error.Syscall.notSupported(operation: .open)
        let b = ISO_9945.Kernel.File.Direct.Error.Syscall.notSupported(operation: .open)
        let c = ISO_9945.Kernel.File.Direct.Error.Syscall.notSupported(operation: .read)
        #expect(a == b)
        #expect(a != c)
    }
}

// MARK: - Associated Value Tests

extension ISO_9945.Kernel.File.Direct.Error.Syscall.Test.Unit {
    @Test
    func `platform stores error code`() {
        let syscall = ISO_9945.Kernel.File.Direct.Error.Syscall.platform(code: .posix(42), operation: .open)
        if case .platform(let code, _) = syscall {
            if case .posix(let errno) = code {
                #expect(errno == 42)
            } else {
                Issue.record("Expected .posix code")
            }
        } else {
            Issue.record("Expected .platform case")
        }
    }

    @Test
    func `platform stores operation`() {
        let syscall = ISO_9945.Kernel.File.Direct.Error.Syscall.platform(code: .posix(1), operation: .write)
        if case .platform(_, let operation) = syscall {
            if case .write = operation {
                // Expected
            } else {
                Issue.record("Expected .write operation")
            }
        } else {
            Issue.record("Expected .platform case")
        }
    }

    @Test
    func `invalidDescriptor stores operation`() {
        let syscall = ISO_9945.Kernel.File.Direct.Error.Syscall.invalidDescriptor(operation: .read)
        if case .invalidDescriptor(let operation) = syscall {
            if case .read = operation {
                // Expected
            } else {
                Issue.record("Expected .read operation")
            }
        } else {
            Issue.record("Expected .invalidDescriptor case")
        }
    }

    @Test
    func `alignmentViolation stores operation`() {
        let syscall = ISO_9945.Kernel.File.Direct.Error.Syscall.alignmentViolation(operation: .write)
        if case .alignmentViolation(let operation) = syscall {
            if case .write = operation {
                // Expected
            } else {
                Issue.record("Expected .write operation")
            }
        } else {
            Issue.record("Expected .alignmentViolation case")
        }
    }

    @Test
    func `notSupported stores operation`() {
        let syscall = ISO_9945.Kernel.File.Direct.Error.Syscall.notSupported(operation: .open)
        if case .notSupported(let operation) = syscall {
            if case .open = operation {
                // Expected
            } else {
                Issue.record("Expected .open operation")
            }
        } else {
            Issue.record("Expected .notSupported case")
        }
    }
}

// MARK: - Edge Cases

extension ISO_9945.Kernel.File.Direct.Error.Syscall.Test.EdgeCase {
    @Test
    func `different cases with same operation are distinct`() {
        let invalidDesc = ISO_9945.Kernel.File.Direct.Error.Syscall.invalidDescriptor(operation: .read)
        let alignment = ISO_9945.Kernel.File.Direct.Error.Syscall.alignmentViolation(operation: .read)
        let notSupp = ISO_9945.Kernel.File.Direct.Error.Syscall.notSupported(operation: .read)
        #expect(invalidDesc != alignment)
        #expect(alignment != notSupp)
        #expect(invalidDesc != notSupp)
    }

    @Test
    func `platform errors with different codes are distinct`() {
        let error1 = ISO_9945.Kernel.File.Direct.Error.Syscall.platform(code: .posix(1), operation: .open)
        let error2 = ISO_9945.Kernel.File.Direct.Error.Syscall.platform(code: .posix(2), operation: .open)
        #expect(error1 != error2)
    }

    @Test
    func `platform errors with different operations are distinct`() {
        let error1 = ISO_9945.Kernel.File.Direct.Error.Syscall.platform(code: .posix(1), operation: .read)
        let error2 = ISO_9945.Kernel.File.Direct.Error.Syscall.platform(code: .posix(1), operation: .write)
        #expect(error1 != error2)
    }
}
