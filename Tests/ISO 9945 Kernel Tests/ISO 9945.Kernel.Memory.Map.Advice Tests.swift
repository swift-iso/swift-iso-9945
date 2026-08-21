import Error_Primitives
import ISO_9945_Kernel_Test_Support
import Path_Primitives
import Tagged_Primitives_Standard_Library_Integration
import Testing

@testable import ISO_9945_Kernel

extension Memory.Map.Advice {
    @Suite
    struct Test {
        @Suite struct Unit {}
        @Suite struct EdgeCase {}
    }
}

extension Memory.Map.Advice.Test.Unit {
    @Test
    func `Advice from rawValue`() {
        let advice = Memory.Map.Advice(rawValue: 0)
        #expect(advice.rawValue == 0)
    }

    @Test
    func `normal constant exists`() {
        let advice = Memory.Map.Advice.normal

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
        set.insert(.normal)
        #expect(set.count == 2)
    }
}

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
