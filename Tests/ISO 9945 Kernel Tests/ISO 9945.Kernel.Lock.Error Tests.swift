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


extension ISO_9945.Kernel.Lock.Error {
    @Suite
    struct Test {
        @Suite struct Unit {}
        @Suite struct EdgeCase {}
    }
}

// MARK: - Unit Tests

extension ISO_9945.Kernel.Lock.Error.Test.Unit {
    @Test
    func `contention case exists`() {
        let error = ISO_9945.Kernel.Lock.Error.contention
        if case .contention = error {
            // Expected
        } else {
            Issue.record("Expected .contention case")
        }
    }

    @Test
    func `deadlock case exists`() {
        let error = ISO_9945.Kernel.Lock.Error.deadlock
        if case .deadlock = error {
            // Expected
        } else {
            Issue.record("Expected .deadlock case")
        }
    }

    @Test
    func `unavailable case exists`() {
        let error = ISO_9945.Kernel.Lock.Error.unavailable
        if case .unavailable = error {
            // Expected
        } else {
            Issue.record("Expected .unavailable case")
        }
    }
}

// MARK: - Static Properties Tests

extension ISO_9945.Kernel.Lock.Error.Test.Unit {
    @Test
    func `timedOut equals contention`() {
        #expect(ISO_9945.Kernel.Lock.Error.timedOut == ISO_9945.Kernel.Lock.Error.contention)
    }

    @Test
    func `wouldBlock equals contention`() {
        #expect(ISO_9945.Kernel.Lock.Error.wouldBlock == ISO_9945.Kernel.Lock.Error.contention)
    }

    @Test
    func `timedOut and wouldBlock are equal`() {
        #expect(ISO_9945.Kernel.Lock.Error.timedOut == ISO_9945.Kernel.Lock.Error.wouldBlock)
    }
}

// MARK: - Description Tests

extension ISO_9945.Kernel.Lock.Error.Test.Unit {
    @Test
    func `contention description`() {
        let error = ISO_9945.Kernel.Lock.Error.contention
        #expect(error.description == "lock contention")
    }

    @Test
    func `deadlock description`() {
        let error = ISO_9945.Kernel.Lock.Error.deadlock
        #expect(error.description == "deadlock detected")
    }

    @Test
    func `unavailable description`() {
        let error = ISO_9945.Kernel.Lock.Error.unavailable
        #expect(error.description == "no locks available")
    }
}

// MARK: - Conformance Tests

extension ISO_9945.Kernel.Lock.Error.Test.Unit {
    @Test
    func `Error conforms to Swift.Error`() {
        let error: any Swift.Error = ISO_9945.Kernel.Lock.Error.contention
        #expect(error is ISO_9945.Kernel.Lock.Error)
    }

    @Test
    func `Error is Sendable`() {
        let error: any Sendable = ISO_9945.Kernel.Lock.Error.contention
        #expect(error is ISO_9945.Kernel.Lock.Error)
    }

    @Test
    func `Error is Equatable`() {
        let a = ISO_9945.Kernel.Lock.Error.contention
        let b = ISO_9945.Kernel.Lock.Error.contention
        let c = ISO_9945.Kernel.Lock.Error.deadlock
        #expect(a == b)
        #expect(a != c)
    }

    @Test
    func `Error is Hashable`() {
        var set = Set<ISO_9945.Kernel.Lock.Error>()
        set.insert(.contention)
        set.insert(.deadlock)
        set.insert(.unavailable)
        set.insert(.contention)  // duplicate
        #expect(set.count == 3)
    }

    @Test
    func `Error is CustomStringConvertible`() {
        let error: any CustomStringConvertible = ISO_9945.Kernel.Lock.Error.contention
        #expect(!error.description.isEmpty)
    }
}

// MARK: - Edge Cases

extension ISO_9945.Kernel.Lock.Error.Test.EdgeCase {
    @Test
    func `all cases are distinct`() {
        let cases: [ISO_9945.Kernel.Lock.Error] = [
            .contention,
            .deadlock,
            .unavailable,
        ]

        for i in 0..<cases.count {
            for j in (i + 1)..<cases.count {
                #expect(cases[i] != cases[j])
            }
        }
    }

    @Test
    func `all descriptions are non-empty`() {
        let cases: [ISO_9945.Kernel.Lock.Error] = [
            .contention,
            .deadlock,
            .unavailable,
        ]

        for error in cases {
            #expect(!error.description.isEmpty)
        }
    }

    @Test
    func `all descriptions are unique`() {
        let descriptions = [
            ISO_9945.Kernel.Lock.Error.contention.description,
            ISO_9945.Kernel.Lock.Error.deadlock.description,
            ISO_9945.Kernel.Lock.Error.unavailable.description,
        ]

        let unique = Set(descriptions)
        #expect(unique.count == descriptions.count)
    }

    @Test
    func `hash values for different errors are different`() {
        let contentionHash = ISO_9945.Kernel.Lock.Error.contention.hashValue
        let deadlockHash = ISO_9945.Kernel.Lock.Error.deadlock.hashValue
        let unavailableHash = ISO_9945.Kernel.Lock.Error.unavailable.hashValue

        // Hash values should generally be different for different cases
        // (not guaranteed but highly likely)
        #expect(contentionHash != deadlockHash || deadlockHash != unavailableHash)
    }
}
