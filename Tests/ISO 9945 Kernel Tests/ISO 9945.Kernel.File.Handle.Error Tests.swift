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
import Kernel_Primitives_Test_Support


extension Kernel.File.Handle.Error {
    @Suite
    struct Test {
        @Suite struct Unit {}
        @Suite struct EdgeCase {}
    }
}

// MARK: - Unit Tests

extension Kernel.File.Handle.Error.Test.Unit {
    @Test
    func `invalidHandle case exists`() {
        let error = Kernel.File.Handle.Error.invalidHandle
        if case .invalidHandle = error {
            // Expected
        } else {
            Issue.record("Expected .invalidHandle case")
        }
    }

    @Test
    func `endOfFile case exists`() {
        let error = Kernel.File.Handle.Error.endOfFile
        if case .endOfFile = error {
            // Expected
        } else {
            Issue.record("Expected .endOfFile case")
        }
    }

    @Test
    func `noSpace case exists`() {
        let error = Kernel.File.Handle.Error.noSpace
        if case .noSpace = error {
            // Expected
        } else {
            Issue.record("Expected .noSpace case")
        }
    }

    @Test
    func `misalignedBuffer case stores address and alignment`() {
        let error = Kernel.File.Handle.Error.misalignedBuffer(address: 0x1234, required: .`512`)
        if case .misalignedBuffer(let addr, let req) = error {
            #expect(addr == 0x1234)
            #expect(req == .`512`)
        } else {
            Issue.record("Expected .misalignedBuffer case")
        }
    }

    @Test
    func `misalignedOffset case stores offset and alignment`() {
        let error = Kernel.File.Handle.Error.misalignedOffset(offset: 1000, required: .`512`)
        if case .misalignedOffset(let off, let req) = error {
            #expect(off == 1000)
            #expect(req == .`512`)
        } else {
            Issue.record("Expected .misalignedOffset case")
        }
    }

    @Test
    func `invalidLength case stores length and required multiple`() {
        let error = Kernel.File.Handle.Error.invalidLength(length: 100, requiredMultiple: .`512`)
        if case .invalidLength(let len, let req) = error {
            #expect(len == 100)
            #expect(req == .`512`)
        } else {
            Issue.record("Expected .invalidLength case")
        }
    }

    @Test
    func `requirementsUnknown case exists`() {
        let error = Kernel.File.Handle.Error.requirementsUnknown
        if case .requirementsUnknown = error {
            // Expected
        } else {
            Issue.record("Expected .requirementsUnknown case")
        }
    }

    @Test
    func `alignmentViolation case stores operation`() {
        let error = Kernel.File.Handle.Error.alignmentViolation(operation: .read)
        if case .alignmentViolation(let op) = error {
            #expect(op == .read)
        } else {
            Issue.record("Expected .alignmentViolation case")
        }
    }

    @Test
    func `platform case stores code and operation`() {
        let code = Error_Primitives.Error.Code.posix(22)
        let error = Kernel.File.Handle.Error.platform(code: code, operation: .write)
        if case .platform(let storedCode, let op) = error {
            #expect(storedCode == code)
            #expect(op == .write)
        } else {
            Issue.record("Expected .platform case")
        }
    }
}

// MARK: - Description Tests

extension Kernel.File.Handle.Error.Test.Unit {
    @Test
    func `invalidHandle description`() {
        #expect(Kernel.File.Handle.Error.invalidHandle.description == "Invalid file handle")
    }

    @Test
    func `endOfFile description`() {
        #expect(Kernel.File.Handle.Error.endOfFile.description == "End of file")
    }

    @Test
    func `noSpace description`() {
        #expect(Kernel.File.Handle.Error.noSpace.description == "No space left on device")
    }

    @Test
    func `misalignedBuffer description contains address`() {
        let error = Kernel.File.Handle.Error.misalignedBuffer(address: 0x1234, required: .`512`)
        #expect(error.description.contains("Buffer address"))
        #expect(error.description.contains("not aligned"))
    }

    @Test
    func `misalignedOffset description contains offset`() {
        let error = Kernel.File.Handle.Error.misalignedOffset(offset: 1000, required: .`512`)
        #expect(error.description.contains("File offset"))
        #expect(error.description.contains("1000"))
    }

    @Test
    func `invalidLength description contains length`() {
        let error = Kernel.File.Handle.Error.invalidLength(length: 100, requiredMultiple: .`512`)
        #expect(error.description.contains("Length"))
        #expect(error.description.contains("100"))
    }

    @Test
    func `requirementsUnknown description`() {
        #expect(Kernel.File.Handle.Error.requirementsUnknown.description == "Direct I/O requirements unknown")
    }

    @Test
    func `alignmentViolation description contains operation`() {
        let error = Kernel.File.Handle.Error.alignmentViolation(operation: .read)
        #expect(error.description.contains("Alignment violation"))
        #expect(error.description.contains("read"))
    }

    @Test
    func `platform description contains operation`() {
        let error = Kernel.File.Handle.Error.platform(code: .posix(22), operation: .write)
        #expect(error.description.contains("write"))
    }
}

// MARK: - Conformance Tests

extension Kernel.File.Handle.Error.Test.Unit {
    @Test
    func `Error conforms to Swift.Error`() {
        let error: any Swift.Error = Kernel.File.Handle.Error.invalidHandle
        #expect(error is Kernel.File.Handle.Error)
    }

    @Test
    func `Error is Sendable`() {
        let error: any Sendable = Kernel.File.Handle.Error.invalidHandle
        #expect(error is Kernel.File.Handle.Error)
    }

    @Test
    func `Error is Equatable`() {
        let a = Kernel.File.Handle.Error.invalidHandle
        let b = Kernel.File.Handle.Error.invalidHandle
        let c = Kernel.File.Handle.Error.endOfFile
        #expect(a == b)
        #expect(a != c)
    }
}

// MARK: - Operation Enum Tests

extension Kernel.File.Handle.Error.Test.Unit {
    @Test
    func `Operation read case`() {
        let op = Kernel.File.Handle.Operation.read
        #expect(op.rawValue == "read")
    }

    @Test
    func `Operation write case`() {
        let op = Kernel.File.Handle.Operation.write
        #expect(op.rawValue == "write")
    }

    @Test
    func `Operation seek case`() {
        let op = Kernel.File.Handle.Operation.seek
        #expect(op.rawValue == "seek")
    }

    @Test
    func `Operation sync case`() {
        let op = Kernel.File.Handle.Operation.sync
        #expect(op.rawValue == "sync")
    }
}

// MARK: - Edge Cases

extension Kernel.File.Handle.Error.Test.EdgeCase {
    @Test
    func `simple cases are distinct`() {
        let cases: [Kernel.File.Handle.Error] = [
            .invalidHandle,
            .endOfFile,
            .noSpace,
            .requirementsUnknown,
        ]

        for i in 0..<cases.count {
            for j in (i + 1)..<cases.count {
                #expect(cases[i] != cases[j])
            }
        }
    }

    @Test
    func `different operations are distinct in alignmentViolation`() {
        let read = Kernel.File.Handle.Error.alignmentViolation(operation: .read)
        let write = Kernel.File.Handle.Error.alignmentViolation(operation: .write)
        let seek = Kernel.File.Handle.Error.alignmentViolation(operation: .seek)
        #expect(read != write)
        #expect(write != seek)
    }

    @Test
    func `different addresses in misalignedBuffer are distinct`() {
        let a = Kernel.File.Handle.Error.misalignedBuffer(address: 100, required: .`512`)
        let b = Kernel.File.Handle.Error.misalignedBuffer(address: 200, required: .`512`)
        #expect(a != b)
    }

    @Test
    func `different alignments in misalignedBuffer are distinct`() {
        let a = Kernel.File.Handle.Error.misalignedBuffer(address: 100, required: .`512`)
        let b = Kernel.File.Handle.Error.misalignedBuffer(address: 100, required: .`4096`)
        #expect(a != b)
    }
}
