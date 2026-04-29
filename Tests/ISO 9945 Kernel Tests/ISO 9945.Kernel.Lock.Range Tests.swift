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

@testable import Kernel_File_Primitives

extension Kernel.Lock.Range {
    @Suite
    struct Test {
        @Suite struct Unit {}
        @Suite struct EdgeCase {}
    }
}

// MARK: - Unit Tests

extension Kernel.Lock.Range.Test.Unit {
    @Test
    func `file case exists`() {
        let range = Kernel.Lock.Range.file
        if case .file = range {
            // Expected
        } else {
            Issue.record("Expected .file case")
        }
    }

    @Test
    func `bytes case exists with start and end`() {
        let start = Kernel.File.Offset(100)
        let end = Kernel.File.Offset(200)
        let range = Kernel.Lock.Range.bytes(start: start, end: end)
        if case .bytes(let s, let e) = range {
            #expect(s == start)
            #expect(e == end)
        } else {
            Issue.record("Expected .bytes case")
        }
    }

    @Test
    func `bytes factory with start and length`() {
        let start = Kernel.File.Offset(100)
        let length = Kernel.File.Size(50)
        let range = Kernel.Lock.Range.bytes(start: start, length: length)
        if case .bytes(let s, let e) = range {
            #expect(s == start)
            #expect(e == start + length)
        } else {
            Issue.record("Expected .bytes case")
        }
    }
}

// MARK: - Conformance Tests

extension Kernel.Lock.Range.Test.Unit {
    @Test
    func `Range is Sendable`() {
        let range: any Sendable = Kernel.Lock.Range.file
        #expect(range is Kernel.Lock.Range)
    }

    @Test
    func `Range is Equatable`() {
        let a = Kernel.Lock.Range.file
        let b = Kernel.Lock.Range.file
        let c = Kernel.Lock.Range.bytes(start: 0, end: 100)
        #expect(a == b)
        #expect(a != c)
    }

    @Test
    func `Range is Hashable`() {
        var set = Set<Kernel.Lock.Range>()
        set.insert(.file)
        set.insert(.bytes(start: 0, end: 100))
        set.insert(.bytes(start: 100, end: 200))
        set.insert(.file)  // duplicate
        #expect(set.count == 3)
    }
}

// MARK: - Bytes Range Tests

extension Kernel.Lock.Range.Test.Unit {
    @Test
    func `bytes ranges with same values are equal`() {
        let a = Kernel.Lock.Range.bytes(start: 100, end: 200)
        let b = Kernel.Lock.Range.bytes(start: 100, end: 200)
        #expect(a == b)
    }

    @Test
    func `bytes ranges with different starts are distinct`() {
        let a = Kernel.Lock.Range.bytes(start: 100, end: 200)
        let b = Kernel.Lock.Range.bytes(start: 150, end: 200)
        #expect(a != b)
    }

    @Test
    func `bytes ranges with different ends are distinct`() {
        let a = Kernel.Lock.Range.bytes(start: 100, end: 200)
        let b = Kernel.Lock.Range.bytes(start: 100, end: 250)
        #expect(a != b)
    }

    @Test
    func `bytes factory produces correct end offset`() {
        let range = Kernel.Lock.Range.bytes(start: 1000, length: 500)
        if case .bytes(_, let end) = range {
            #expect(end == Kernel.File.Offset(1500))
        } else {
            Issue.record("Expected .bytes case")
        }
    }
}

// MARK: - Edge Cases

extension Kernel.Lock.Range.Test.EdgeCase {
    @Test
    func `file and bytes are distinct`() {
        let file = Kernel.Lock.Range.file
        let bytes = Kernel.Lock.Range.bytes(start: 0, end: .max)
        #expect(file != bytes)
    }

    @Test
    func `bytes with zero length`() {
        let range = Kernel.Lock.Range.bytes(start: 100, length: 0)
        if case .bytes(let start, let end) = range {
            #expect(start == end)
            #expect(start == Kernel.File.Offset(100))
        } else {
            Issue.record("Expected .bytes case")
        }
    }

    @Test
    func `bytes with zero start`() {
        let range = Kernel.Lock.Range.bytes(start: 0, end: 1000)
        if case .bytes(let start, _) = range {
            #expect(start == Kernel.File.Offset(0))
        } else {
            Issue.record("Expected .bytes case")
        }
    }

    @Test
    func `bytes with max end (to EOF)`() {
        let range = Kernel.Lock.Range.bytes(start: 0, end: .max)
        if case .bytes(_, let end) = range {
            #expect(end == .max)
        } else {
            Issue.record("Expected .bytes case")
        }
    }

    @Test
    func `bytes factory with max length`() {
        let range = Kernel.Lock.Range.bytes(start: 0, length: Kernel.File.Size(Kernel.File.Offset.max.rawValue))
        if case .bytes(let start, let end) = range {
            #expect(start == Kernel.File.Offset(0))
            #expect(end == .max)
        } else {
            Issue.record("Expected .bytes case")
        }
    }

    @Test
    func `adjacent ranges are distinct`() {
        let a = Kernel.Lock.Range.bytes(start: 0, end: 100)
        let b = Kernel.Lock.Range.bytes(start: 100, end: 200)
        #expect(a != b)
    }
}
