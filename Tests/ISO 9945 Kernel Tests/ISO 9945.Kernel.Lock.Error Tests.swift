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


extension Kernel.Lock.Error {
    @Suite
    struct Test {
        @Suite struct Unit {}
        @Suite struct EdgeCase {}
    }
}

// MARK: - Unit Tests

extension Kernel.Lock.Error.Test.Unit {
    @Test
    func `contention case exists`() {
        let error = Kernel.Lock.Error.contention
        if case .contention = error {
            // Expected
        } else {
            Issue.record("Expected .contention case")
        }
    }

    @Test
    func `deadlock case exists`() {
        let error = Kernel.Lock.Error.deadlock
        if case .deadlock = error {
            // Expected
        } else {
            Issue.record("Expected .deadlock case")
        }
    }

    @Test
    func `unavailable case exists`() {
        let error = Kernel.Lock.Error.unavailable
        if case .unavailable = error {
            // Expected
        } else {
            Issue.record("Expected .unavailable case")
        }
    }
}

// MARK: - Static Properties Tests

extension Kernel.Lock.Error.Test.Unit {
    @Test
    func `timedOut equals contention`() {
        #expect(Kernel.Lock.Error.timedOut == Kernel.Lock.Error.contention)
    }

    @Test
    func `wouldBlock equals contention`() {
        #expect(Kernel.Lock.Error.wouldBlock == Kernel.Lock.Error.contention)
    }

    @Test
    func `timedOut and wouldBlock are equal`() {
        #expect(Kernel.Lock.Error.timedOut == Kernel.Lock.Error.wouldBlock)
    }
}

// MARK: - Description Tests

extension Kernel.Lock.Error.Test.Unit {
    @Test
    func `contention description`() {
        let error = Kernel.Lock.Error.contention
        #expect(error.description == "lock contention")
    }

    @Test
    func `deadlock description`() {
        let error = Kernel.Lock.Error.deadlock
        #expect(error.description == "deadlock detected")
    }

    @Test
    func `unavailable description`() {
        let error = Kernel.Lock.Error.unavailable
        #expect(error.description == "no locks available")
    }
}

// MARK: - Conformance Tests

extension Kernel.Lock.Error.Test.Unit {
    @Test
    func `Error conforms to Swift.Error`() {
        let error: any Swift.Error = Kernel.Lock.Error.contention
        #expect(error is Kernel.Lock.Error)
    }

    @Test
    func `Error is Sendable`() {
        let error: any Sendable = Kernel.Lock.Error.contention
        #expect(error is Kernel.Lock.Error)
    }

    @Test
    func `Error is Equatable`() {
        let a = Kernel.Lock.Error.contention
        let b = Kernel.Lock.Error.contention
        let c = Kernel.Lock.Error.deadlock
        #expect(a == b)
        #expect(a != c)
    }

    @Test
    func `Error is Hashable`() {
        var set = Set<Kernel.Lock.Error>()
        set.insert(.contention)
        set.insert(.deadlock)
        set.insert(.unavailable)
        set.insert(.contention)  // duplicate
        #expect(set.count == 3)
    }

    @Test
    func `Error is CustomStringConvertible`() {
        let error: any CustomStringConvertible = Kernel.Lock.Error.contention
        #expect(!error.description.isEmpty)
    }
}

// MARK: - Edge Cases

extension Kernel.Lock.Error.Test.EdgeCase {
    @Test
    func `all cases are distinct`() {
        let cases: [Kernel.Lock.Error] = [
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
        let cases: [Kernel.Lock.Error] = [
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
            Kernel.Lock.Error.contention.description,
            Kernel.Lock.Error.deadlock.description,
            Kernel.Lock.Error.unavailable.description,
        ]

        let unique = Set(descriptions)
        #expect(unique.count == descriptions.count)
    }

    @Test
    func `hash values for different errors are different`() {
        let contentionHash = Kernel.Lock.Error.contention.hashValue
        let deadlockHash = Kernel.Lock.Error.deadlock.hashValue
        let unavailableHash = Kernel.Lock.Error.unavailable.hashValue

        // Hash values should generally be different for different cases
        // (not guaranteed but highly likely)
        #expect(contentionHash != deadlockHash || deadlockHash != unavailableHash)
    }
}
