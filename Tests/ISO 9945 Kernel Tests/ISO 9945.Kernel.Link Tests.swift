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
import Kernel_Primitives

@testable import ISO_9945_Kernel

extension Kernel.Link {
    @Suite
    struct Test {
        @Suite struct Unit {}
        @Suite struct EdgeCase {}
    }
}

// MARK: - Unit Tests

extension Kernel.Link.Test.Unit {
    @Test("Link namespace exists")
    func namespaceExists() {
        _ = Kernel.Link.self
    }

    @Test("Link is an enum")
    func isEnum() {
        let _: Kernel.Link.Type = Kernel.Link.self
    }

    @Test("Link.Count type exists")
    func countTypeExists() {
        let _: Kernel.Link.Count.Type = Kernel.Link.Count.self
    }

    @Test("Link.Error type exists")
    func errorTypeExists() {
        let _: Kernel.Link.Error.Type = Kernel.Link.Error.self
    }
}

// MARK: - Link.Count Tests

extension Kernel.Link.Test.Unit {
    @Test("Link.Count zero constant")
    func zeroConstant() {
        let zero = Kernel.Link.Count.zero
        #expect(zero == 0)
    }
}

// MARK: - Link.Count Conformance Tests

extension Kernel.Link.Test.Unit {
    @Test("Link.Count is Sendable")
    func countIsSendable() {
        let value: any Sendable = Kernel.Link.Count.zero
        #expect(value is Kernel.Link.Count)
    }

    @Test("Link.Count is Equatable")
    func countIsEquatable() {
        let a: Kernel.Link.Count = 1
        let b: Kernel.Link.Count = 1
        let c: Kernel.Link.Count = 2
        #expect(a == b)
        #expect(a != c)
    }

    @Test("Link.Count is Hashable")
    func countIsHashable() {
        let c0 = Kernel.Link.Count.zero
        let c1: Kernel.Link.Count = 1
        var set = Set<Kernel.Link.Count>()
        set.insert(c0)
        set.insert(c1)
        set.insert(c0)  // duplicate
        #expect(set.count == 2)
    }
}

// MARK: - Link.Error Tests

extension Kernel.Link.Test.Unit {
    @Test("Link.Error conforms to Swift.Error")
    func errorIsError() {
        let error: any Swift.Error = Kernel.Link.Error.notFound
        #expect(error is Kernel.Link.Error)
    }

    @Test("Link.Error cases are distinct")
    func errorCasesDistinct() {
        let cases: [Kernel.Link.Error] = [
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

extension Kernel.Link.Test.EdgeCase {
    @Test("Link.Error descriptions are non-empty")
    func errorDescriptionsNonEmpty() {
        let cases: [Kernel.Link.Error] = [
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
