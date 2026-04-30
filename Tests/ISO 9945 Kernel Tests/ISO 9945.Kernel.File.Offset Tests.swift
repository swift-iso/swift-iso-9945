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


// Kernel.File.Offset is a typealias to Coordinate.X<Space>.Value<Int64>
// #Tests cannot be used on typealiases

@Suite("Kernel.File.Offset Tests")
struct FileOffsetTests {

    // MARK: - Basic Initialization

    @Test
    func `Offset from integer literal`() {
        let offset: Kernel.File.Offset = 1000
        #expect(offset == 1000)
    }

    @Test
    func `Offset from Int`() {
        let offset = Kernel.File.Offset(100)
        #expect(offset == 100)
    }

    @Test
    func `Offset from Int64`() {
        let offset = Kernel.File.Offset(Int64(5000))
        #expect(offset == 5000)
    }

    // MARK: - Constants

    @Test
    func `zero constant`() {
        #expect(Kernel.File.Offset.zero == 0)
    }

    @Test
    func `max constant`() {
        #expect(Kernel.File.Offset.max.rawValue == Int64.max)
    }

    // MARK: - Arithmetic with Delta

    @Test
    func `Offset minus Offset equals Delta`() {
        let start: Kernel.File.Offset = 1000
        let end: Kernel.File.Offset = 5000
        let delta = end - start
        #expect(delta == 4000)
    }

    @Test
    func `Offset plus Delta equals Offset`() {
        let offset: Kernel.File.Offset = 1000
        let delta = Kernel.File.Delta(3000)
        let result = offset + delta
        #expect(result == 4000)
    }

    @Test
    func `Offset minus Delta equals Offset`() {
        let offset: Kernel.File.Offset = 5000
        let delta = Kernel.File.Delta(2000)
        let result = offset - delta
        #expect(result == 3000)
    }

    // MARK: - Arithmetic with Size

    @Test
    func `Offset plus Size equals Offset`() {
        let offset: Kernel.File.Offset = 1000
        let size: Kernel.File.Size = 4096
        let result = offset + size
        #expect(result == 5096)
    }

    @Test
    func `Offset minus Size equals Offset`() {
        let offset: Kernel.File.Offset = 5096
        let size: Kernel.File.Size = 4096
        let result = offset - size
        #expect(result == 1000)
    }

    @Test
    func `Offset plus Size in place`() {
        var offset: Kernel.File.Offset = 1000
        let size: Kernel.File.Size = 500
        offset += size
        #expect(offset == 1500)
    }

    @Test
    func `Offset minus Size in place`() {
        var offset: Kernel.File.Offset = 1500
        let size: Kernel.File.Size = 500
        offset -= size
        #expect(offset == 1000)
    }

    // MARK: - Conformances

    @Test
    func `Offset is Equatable`() {
        let a: Kernel.File.Offset = 1000
        let b: Kernel.File.Offset = 1000
        let c: Kernel.File.Offset = 2000
        #expect(a == b)
        #expect(a != c)
    }

    @Test
    func `Offset is Hashable`() {
        var set = Set<Kernel.File.Offset>()
        set.insert(Kernel.File.Offset(1000))
        set.insert(Kernel.File.Offset(2000))
        set.insert(Kernel.File.Offset(1000))  // duplicate
        #expect(set.count == 2)
    }

    @Test
    func `Offset is Sendable`() {
        let offset: any Sendable = Kernel.File.Offset(1000)
        #expect(offset is Kernel.File.Offset)
    }

    @Test
    func `Offset is Comparable`() {
        let a: Kernel.File.Offset = 1000
        let b: Kernel.File.Offset = 2000
        #expect(a < b)
        #expect(b > a)
    }
}

// MARK: - Delta Tests

@Suite("Kernel.File.Delta Tests")
struct FileDeltaTests {

    @Test
    func `Delta from integer literal`() {
        let delta: Kernel.File.Delta = 500
        #expect(delta == 500)
    }

    @Test
    func `Negative Delta`() {
        let delta = Kernel.File.Delta(-100)
        #expect(delta == -100)
    }

    @Test
    func `Delta is Equatable`() {
        let a = Kernel.File.Delta(100)
        let b = Kernel.File.Delta(100)
        let c = Kernel.File.Delta(-100)
        #expect(a == b)
        #expect(a != c)
    }
}
