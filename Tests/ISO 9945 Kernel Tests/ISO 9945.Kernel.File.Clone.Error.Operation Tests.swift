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

import ISO_9945_Kernel
import Tagged_Primitives_Standard_Library_Integration
// Tests use Apple native Testing framework
import Testing

extension ISO_9945.Kernel.File.Clone.Error.Operation {
    @Suite
    struct Test {
        @Suite struct Unit {}
        @Suite struct EdgeCase {}
    }
}

// MARK: - Unit Tests

extension ISO_9945.Kernel.File.Clone.Error.Operation.Test.Unit {
    @Test
    func `clonefile case exists`() {
        let operation = ISO_9945.Kernel.File.Clone.Error.Operation.clonefile
        #expect(operation.rawValue == "clonefile")
    }

    @Test
    func `copyfile case exists`() {
        let operation = ISO_9945.Kernel.File.Clone.Error.Operation.copyfile
        #expect(operation.rawValue == "copyfile")
    }

    @Test
    func `ficlone case exists`() {
        let operation = ISO_9945.Kernel.File.Clone.Error.Operation.ficlone
        #expect(operation.rawValue == "ficlone")
    }

    @Test
    func `copyFileRange case exists`() {
        let operation = ISO_9945.Kernel.File.Clone.Error.Operation.copyFileRange
        #expect(operation.rawValue == "copyFileRange")
    }

    @Test
    func `duplicateExtents case exists`() {
        let operation = ISO_9945.Kernel.File.Clone.Error.Operation.duplicateExtents
        #expect(operation.rawValue == "duplicateExtents")
    }

    @Test
    func `statfs case exists`() {
        let operation = ISO_9945.Kernel.File.Clone.Error.Operation.statfs
        #expect(operation.rawValue == "statfs")
    }

    @Test
    func `stat case exists`() {
        let operation = ISO_9945.Kernel.File.Clone.Error.Operation.stat
        #expect(operation.rawValue == "stat")
    }

    @Test
    func `copy case exists`() {
        let operation = ISO_9945.Kernel.File.Clone.Error.Operation.copy
        #expect(operation.rawValue == "copy")
    }
}

// MARK: - Conformance Tests

extension ISO_9945.Kernel.File.Clone.Error.Operation.Test.Unit {
    @Test
    func `Operation is Sendable`() {
        let operation: any Sendable = ISO_9945.Kernel.File.Clone.Error.Operation.clonefile
        #expect(operation is ISO_9945.Kernel.File.Clone.Error.Operation)
    }

    @Test
    func `Operation is Equatable`() {
        let a = ISO_9945.Kernel.File.Clone.Error.Operation.clonefile
        let b = ISO_9945.Kernel.File.Clone.Error.Operation.clonefile
        let c = ISO_9945.Kernel.File.Clone.Error.Operation.copyfile
        #expect(a == b)
        #expect(a != c)
    }

    @Test
    func `Operation is RawRepresentable`() {
        let operation = ISO_9945.Kernel.File.Clone.Error.Operation.clonefile
        let fromRaw = ISO_9945.Kernel.File.Clone.Error.Operation(rawValue: "clonefile")
        #expect(fromRaw == operation)
    }

    @Test
    func `Operation is Hashable`() {
        var set = Set<ISO_9945.Kernel.File.Clone.Error.Operation>()
        set.insert(.clonefile)
        set.insert(.copyfile)
        set.insert(.clonefile)  // duplicate
        #expect(set.count == 2)
    }
}

// MARK: - Edge Cases

extension ISO_9945.Kernel.File.Clone.Error.Operation.Test.EdgeCase {
    @Test
    func `all operations are distinct`() {
        let operations: [ISO_9945.Kernel.File.Clone.Error.Operation] = [
            .clonefile,
            .copyfile,
            .ficlone,
            .copyFileRange,
            .duplicateExtents,
            .statfs,
            .stat,
            .copy,
        ]

        for i in 0..<operations.count {
            for j in (i + 1)..<operations.count {
                #expect(operations[i] != operations[j])
            }
        }
    }

    @Test
    func `all raw values are distinct`() {
        let rawValues = [
            ISO_9945.Kernel.File.Clone.Error.Operation.clonefile.rawValue,
            ISO_9945.Kernel.File.Clone.Error.Operation.copyfile.rawValue,
            ISO_9945.Kernel.File.Clone.Error.Operation.ficlone.rawValue,
            ISO_9945.Kernel.File.Clone.Error.Operation.copyFileRange.rawValue,
            ISO_9945.Kernel.File.Clone.Error.Operation.duplicateExtents.rawValue,
            ISO_9945.Kernel.File.Clone.Error.Operation.statfs.rawValue,
            ISO_9945.Kernel.File.Clone.Error.Operation.stat.rawValue,
            ISO_9945.Kernel.File.Clone.Error.Operation.copy.rawValue,
        ]

        let uniqueRawValues = Set(rawValues)
        #expect(uniqueRawValues.count == rawValues.count)
    }

    @Test
    func `invalid raw value returns nil`() {
        let operation = ISO_9945.Kernel.File.Clone.Error.Operation(rawValue: "invalid")
        #expect(operation == nil)
    }
}
