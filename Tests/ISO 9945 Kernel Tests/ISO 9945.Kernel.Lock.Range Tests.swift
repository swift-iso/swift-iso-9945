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
import ISO_9945_Kernel_Test_Support


extension ISO_9945.Kernel.Lock.Range {
    @Suite
    struct Test {
        @Suite struct Unit {}
        @Suite struct EdgeCase {}
    }
}

// MARK: - Unit Tests

extension ISO_9945.Kernel.Lock.Range.Test.Unit {
    @Test
    func `file case exists`() {
        let range = ISO_9945.Kernel.Lock.Range.file
        if case .file = range {
            // Expected
        } else {
            Issue.record("Expected .file case")
        }
    }

    @Test
    func `bytes case exists with start and end`() {
        let start = ISO_9945.Kernel.File.Offset(100)
        let end = ISO_9945.Kernel.File.Offset(200)
        let range = ISO_9945.Kernel.Lock.Range.bytes(start: start, end: end)
        if case .bytes(let s, let e) = range {
            #expect(s == start)
            #expect(e == end)
        } else {
            Issue.record("Expected .bytes case")
        }
    }

    @Test
    func `bytes factory with start and length`() {
        let start = ISO_9945.Kernel.File.Offset(100)
        let length = ISO_9945.Kernel.File.Size(50)
        let range = ISO_9945.Kernel.Lock.Range.bytes(start: start, length: length)
        if case .bytes(let s, let e) = range {
            #expect(s == start)
            #expect(e == start + length)
        } else {
            Issue.record("Expected .bytes case")
        }
    }
}

// MARK: - Conformance Tests

extension ISO_9945.Kernel.Lock.Range.Test.Unit {
    @Test
    func `Range is Sendable`() {
        let range: any Sendable = ISO_9945.Kernel.Lock.Range.file
        #expect(range is ISO_9945.Kernel.Lock.Range)
    }

    @Test
    func `Range is Equatable`() {
        let a = ISO_9945.Kernel.Lock.Range.file
        let b = ISO_9945.Kernel.Lock.Range.file
        let c = ISO_9945.Kernel.Lock.Range.bytes(start: 0, end: 100)
        #expect(a == b)
        #expect(a != c)
    }

    @Test
    func `Range is Hashable`() {
        var set = Set<ISO_9945.Kernel.Lock.Range>()
        set.insert(.file)
        set.insert(.bytes(start: 0, end: 100))
        set.insert(.bytes(start: 100, end: 200))
        set.insert(.file)  // duplicate
        #expect(set.count == 3)
    }
}

// MARK: - Bytes Range Tests

extension ISO_9945.Kernel.Lock.Range.Test.Unit {
    @Test
    func `bytes ranges with same values are equal`() {
        let a = ISO_9945.Kernel.Lock.Range.bytes(start: 100, end: 200)
        let b = ISO_9945.Kernel.Lock.Range.bytes(start: 100, end: 200)
        #expect(a == b)
    }

    @Test
    func `bytes ranges with different starts are distinct`() {
        let a = ISO_9945.Kernel.Lock.Range.bytes(start: 100, end: 200)
        let b = ISO_9945.Kernel.Lock.Range.bytes(start: 150, end: 200)
        #expect(a != b)
    }

    @Test
    func `bytes ranges with different ends are distinct`() {
        let a = ISO_9945.Kernel.Lock.Range.bytes(start: 100, end: 200)
        let b = ISO_9945.Kernel.Lock.Range.bytes(start: 100, end: 250)
        #expect(a != b)
    }

    @Test
    func `bytes factory produces correct end offset`() {
        let range = ISO_9945.Kernel.Lock.Range.bytes(start: 1000, length: 500)
        if case .bytes(_, let end) = range {
            #expect(end == ISO_9945.Kernel.File.Offset(1500))
        } else {
            Issue.record("Expected .bytes case")
        }
    }
}

// MARK: - Edge Cases

extension ISO_9945.Kernel.Lock.Range.Test.EdgeCase {
    @Test
    func `file and bytes are distinct`() {
        let file = ISO_9945.Kernel.Lock.Range.file
        let bytes = ISO_9945.Kernel.Lock.Range.bytes(start: 0, end: .max)
        #expect(file != bytes)
    }

    @Test
    func `bytes with zero length`() {
        let range = ISO_9945.Kernel.Lock.Range.bytes(start: 100, length: 0)
        if case .bytes(let start, let end) = range {
            #expect(start == end)
            #expect(start == ISO_9945.Kernel.File.Offset(100))
        } else {
            Issue.record("Expected .bytes case")
        }
    }

    @Test
    func `bytes with zero start`() {
        let range = ISO_9945.Kernel.Lock.Range.bytes(start: 0, end: 1000)
        if case .bytes(let start, _) = range {
            #expect(start == ISO_9945.Kernel.File.Offset(0))
        } else {
            Issue.record("Expected .bytes case")
        }
    }

    @Test
    func `bytes with max end (to EOF)`() {
        let range = ISO_9945.Kernel.Lock.Range.bytes(start: 0, end: .max)
        if case .bytes(_, let end) = range {
            #expect(end == .max)
        } else {
            Issue.record("Expected .bytes case")
        }
    }

    @Test
    func `bytes factory with max length`() {
        let range = ISO_9945.Kernel.Lock.Range.bytes(start: 0, length: ISO_9945.Kernel.File.Size(ISO_9945.Kernel.File.Offset.max.underlying))
        if case .bytes(let start, let end) = range {
            #expect(start == ISO_9945.Kernel.File.Offset(0))
            #expect(end == .max)
        } else {
            Issue.record("Expected .bytes case")
        }
    }

    @Test
    func `adjacent ranges are distinct`() {
        let a = ISO_9945.Kernel.Lock.Range.bytes(start: 0, end: 100)
        let b = ISO_9945.Kernel.Lock.Range.bytes(start: 100, end: 200)
        #expect(a != b)
    }
}
