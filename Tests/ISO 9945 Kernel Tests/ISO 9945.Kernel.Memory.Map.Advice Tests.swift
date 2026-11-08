import Error
import ISO_9945_Kernel_Test_Support
import Path
import Tagged
import Testing

@testable import ISO_9945_Kernel

enum `Memory.Map.Advice Tests` {}

extension `Memory.Map.Advice Tests` {
    @Suite
    struct Test {
        @Suite struct Unit {}
        @Suite struct `Edge Case` {}
    }
}

extension `Memory.Map.Advice Tests`.Test.Unit {
    @Test
    func `Advice from rawValue`() {
        let advice = Memory.Map.Advice(rawValue: 0)
        #expect(advice.rawValue == 0)
    }

}

extension `Memory.Map.Advice Tests`.Test.Unit {
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

extension `Memory.Map.Advice Tests`.Test.`Edge Case` {
    @Test
    func `all advice types are distinct`() {
        let advices: [Memory.Map.Advice] = [
            .normal,
            .sequential,
            .random,
            .willNeed,
            .dontNeed,
        ]

        (0..<advices.count).forEach { i in
            ((i + 1)..<advices.count).forEach { j in
                #expect(advices[i] != advices[j])
            }
        }
    }
}
