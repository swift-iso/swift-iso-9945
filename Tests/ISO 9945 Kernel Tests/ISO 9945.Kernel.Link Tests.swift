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

import Error_Primitives
import ISO_9945_Kernel_Test_Support
import Path_Primitives
import Tagged_Primitives_Standard_Library_Integration
import Testing

@testable import ISO_9945_Kernel

extension ISO_9945.Kernel.Link {
    @Suite
    struct Test {
        @Suite struct Unit {}
        @Suite struct EdgeCase {}
    }
}

// MARK: - Unit Tests

extension ISO_9945.Kernel.Link.Test.Unit {
    @Test
    func `Link namespace exists`() {
        _ = ISO_9945.Kernel.Link.self
    }

    @Test
    func `Link is an enum`() {
        let _: ISO_9945.Kernel.Link.Type = ISO_9945.Kernel.Link.self
    }

    @Test
    func `Link.Count type exists`() {
        let _: ISO_9945.Kernel.Link.Count.Type = ISO_9945.Kernel.Link.Count.self
    }

    @Test
    func `Link.Error type exists`() {
        let _: ISO_9945.Kernel.Link.Error.Type = ISO_9945.Kernel.Link.Error.self
    }
}

// MARK: - Link.Count Tests

extension ISO_9945.Kernel.Link.Test.Unit {
    @Test
    func `Link.Count zero constant`() {
        let zero = ISO_9945.Kernel.Link.Count.zero
        #expect(zero == 0)
    }
}

// MARK: - Link.Count Conformance Tests

extension ISO_9945.Kernel.Link.Test.Unit {
    @Test
    func `Link.Count is Sendable`() {
        let value: any Sendable = ISO_9945.Kernel.Link.Count.zero
        #expect(value is ISO_9945.Kernel.Link.Count)
    }

    @Test
    func `Link.Count is Equatable`() {
        let a: ISO_9945.Kernel.Link.Count = 1
        let b: ISO_9945.Kernel.Link.Count = 1
        let c: ISO_9945.Kernel.Link.Count = 2
        #expect(a == b)
        #expect(a != c)
    }

    @Test
    func `Link.Count is Hashable`() {
        let c0 = ISO_9945.Kernel.Link.Count.zero
        let c1: ISO_9945.Kernel.Link.Count = 1
        var set = Set<ISO_9945.Kernel.Link.Count>()
        set.insert(c0)
        set.insert(c1)
        set.insert(c0)  // duplicate
        #expect(set.count == 2)
    }
}

// MARK: - Link.Error Tests

extension ISO_9945.Kernel.Link.Test.Unit {
    @Test
    func `Link.Error conforms to Swift.Error`() {
        let error: any Swift.Error = ISO_9945.Kernel.Link.Error.notFound
        #expect(error is ISO_9945.Kernel.Link.Error)
    }

    @Test
    func `Link.Error cases are distinct`() {
        let cases: [ISO_9945.Kernel.Link.Error] = [
            .notFound, .permission, .exists, .crossDevice,
            .isDirectory, .notDirectory, .readOnly, .tooManyLinks,
            .noSpace, .loop, .nameTooLong,
        ]
        for i in 0..<cases.count {
            for j in (i + 1)..<cases.count {
                #expect(cases[i] != cases[j])
            }
        }
    }
}

// MARK: - Edge Cases

extension ISO_9945.Kernel.Link.Test.EdgeCase {
    @Test
    func `Link.Error descriptions are non-empty`() {
        let cases: [ISO_9945.Kernel.Link.Error] = [
            .notFound, .permission, .exists, .crossDevice,
            .isDirectory, .notDirectory, .readOnly, .tooManyLinks,
            .noSpace, .loop, .nameTooLong,
        ]
        for error in cases {
            let description = Swift.String(describing: error)
            #expect(!description.isEmpty)
        }
    }
}
