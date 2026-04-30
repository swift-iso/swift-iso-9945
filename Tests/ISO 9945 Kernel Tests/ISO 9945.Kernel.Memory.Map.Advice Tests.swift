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
import ISO_9945_Kernel_Test_Support
import ISO_9945_Kernel
import Kernel_Primitives_Core
import Kernel_Event_Primitives
import Kernel_File_Primitives
import Path_Primitives
import Error_Primitives

@testable import ISO_9945_Kernel

extension Memory.Map.Advice {
    @Suite
    struct Test {
        @Suite struct Unit {}
        @Suite struct EdgeCase {}
    }
}

// MARK: - Unit Tests

extension Memory.Map.Advice.Test.Unit {
    @Test
    func `Advice from rawValue`() {
        let advice = Memory.Map.Advice(rawValue: 0)
        #expect(advice.rawValue == 0)
    }

    @Test
    func `normal constant exists`() {
        let advice = Memory.Map.Advice.normal
        // Normal is typically 0 on most platforms
        _ = advice.rawValue
    }

    @Test
    func `sequential constant exists`() {
        let advice = Memory.Map.Advice.sequential
        _ = advice.rawValue
    }

    @Test
    func `random constant exists`() {
        let advice = Memory.Map.Advice.random
        _ = advice.rawValue
    }

    @Test
    func `willNeed constant exists`() {
        let advice = Memory.Map.Advice.willNeed
        _ = advice.rawValue
    }

    @Test
    func `dontNeed constant exists`() {
        let advice = Memory.Map.Advice.dontNeed
        _ = advice.rawValue
    }
}

// MARK: - Conformance Tests

extension Memory.Map.Advice.Test.Unit {
    @Test
    func `Advice is Sendable`() {
        let advice: any Sendable = Memory.Map.Advice.normal
        #expect(advice is Memory.Map.Advice)
    }

    @Test
    func `Advice is Equatable`() {
        let a = Memory.Map.Advice.normal
        let b = Memory.Map.Advice.normal
        let c = Memory.Map.Advice.sequential
        #expect(a == b)
        #expect(a != c)
    }

    @Test
    func `Advice is Hashable`() {
        var set = Set<Memory.Map.Advice>()
        set.insert(.normal)
        set.insert(.sequential)
        set.insert(.normal)  // duplicate
        #expect(set.count == 2)
    }
}

// MARK: - Edge Cases

extension Memory.Map.Advice.Test.EdgeCase {
    @Test
    func `all advice types are distinct`() {
        let advices: [Memory.Map.Advice] = [
            .normal,
            .sequential,
            .random,
            .willNeed,
            .dontNeed,
        ]

        for i in 0..<advices.count {
            for j in (i + 1)..<advices.count {
                #expect(advices[i] != advices[j])
            }
        }
    }
}
