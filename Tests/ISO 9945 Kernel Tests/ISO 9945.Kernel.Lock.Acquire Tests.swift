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
import Clock_Primitives


extension Kernel.Lock.Acquire {
    @Suite
    struct Test {
        @Suite struct Unit {}
        @Suite struct EdgeCase {}
    }
}

// MARK: - Unit Tests

extension Kernel.Lock.Acquire.Test.Unit {
    @Test
    func `try case exists`() {
        let acquire = Kernel.Lock.Acquire.try
        if case .try = acquire {
            // Expected
        } else {
            Issue.record("Expected .try case")
        }
    }

    @Test
    func `wait case exists`() {
        let acquire = Kernel.Lock.Acquire.wait
        if case .wait = acquire {
            // Expected
        } else {
            Issue.record("Expected .wait case")
        }
    }

    @Test
    func `deadline case exists`() {
        let deadline = Clock_Primitives.Clock.Continuous.Instant(nanoseconds: 5_000_000_000)
        let acquire = Kernel.Lock.Acquire.deadline(deadline)
        if case .deadline(let d) = acquire {
            #expect(d == deadline)
        } else {
            Issue.record("Expected .deadline case")
        }
    }
}

// MARK: - Conformance Tests

extension Kernel.Lock.Acquire.Test.Unit {
    @Test
    func `Acquire is Sendable`() {
        let acquire: any Sendable = Kernel.Lock.Acquire.wait
        #expect(acquire is Kernel.Lock.Acquire)
    }

    @Test
    func `Acquire is Equatable`() {
        let a = Kernel.Lock.Acquire.wait
        let b = Kernel.Lock.Acquire.wait
        let c = Kernel.Lock.Acquire.try
        #expect(a == b)
        #expect(a != c)
    }

    @Test
    func `try and wait are distinct`() {
        let tryAcquire = Kernel.Lock.Acquire.try
        let waitAcquire = Kernel.Lock.Acquire.wait
        #expect(tryAcquire != waitAcquire)
    }

    @Test
    func `deadlines with same instant are equal`() {
        let instant = Clock_Primitives.Clock.Continuous.Instant(nanoseconds: 10_000_000_000)
        let a = Kernel.Lock.Acquire.deadline(instant)
        let b = Kernel.Lock.Acquire.deadline(instant)
        #expect(a == b)
    }

    @Test
    func `deadlines with different instants are distinct`() {
        let a = Kernel.Lock.Acquire.deadline(Clock_Primitives.Clock.Continuous.Instant(nanoseconds: 1_000_000_000))
        let b = Kernel.Lock.Acquire.deadline(Clock_Primitives.Clock.Continuous.Instant(nanoseconds: 2_000_000_000))
        #expect(a != b)
    }
}

// MARK: - Edge Cases

extension Kernel.Lock.Acquire.Test.EdgeCase {
    @Test
    func `all cases are distinct`() {
        let cases: [Kernel.Lock.Acquire] = [
            .try,
            .wait,
            .deadline(Clock_Primitives.Clock.Continuous.Instant(nanoseconds: 42)),
        ]

        for i in 0..<cases.count {
            for j in (i + 1)..<cases.count {
                #expect(cases[i] != cases[j])
            }
        }
    }

    @Test
    func `deadline in the past`() {
        let pastInstant = Clock_Primitives.Clock.Continuous.Instant(nanoseconds: 0)
        let acquire = Kernel.Lock.Acquire.deadline(pastInstant)
        if case .deadline(let deadline) = acquire {
            #expect(deadline == pastInstant)
        } else {
            Issue.record("Expected .deadline case")
        }
    }
}
