import Error
import ISO_9945_Kernel_Test_Support
import Path
import Tagged_Standard_Library_Integration
import Testing

@testable import ISO_9945_Kernel

extension Memory.Map.Options {
    @Suite
    struct Test {
        @Suite struct Unit {}
        @Suite struct EdgeCase {}
    }
}

extension Memory.Map.Options.Test.Unit {
    @Test
    func `shared and private are distinct`() {
        let shared = Memory.Map.Options.shared
        let priv = Memory.Map.Options.private

        #expect(shared != priv)
        #expect(shared.rawValue != priv.rawValue)
    }

    @Test
    func `anonymous flag exists`() {
        let anon = Memory.Map.Options.anonymous
        #expect(anon.rawValue != 0)
    }

    @Test
    func `fixed flag exists`() {
        let fixed = Memory.Map.Options.fixed
        #expect(fixed.rawValue != 0)
    }

    @Test
    func `bitwise OR combines flags`() {
        let priv = Memory.Map.Options.private
        let anon = Memory.Map.Options.anonymous
        let combined = priv | anon

        #expect(combined.rawValue == (priv.rawValue | anon.rawValue))
    }

    @Test
    func `Options is Equatable`() {
        let a = Memory.Map.Options.shared
        let b = Memory.Map.Options.shared
        let c = Memory.Map.Options.private

        #expect(a == b)
        #expect(a != c)
    }

    @Test
    func `Options is Hashable`() {
        var set = Set<Memory.Map.Options>()
        set.insert(.shared)
        set.insert(.private)
        set.insert(.shared)

        #expect(set.count == 2)
        #expect(set.contains(.shared))
        #expect(set.contains(.private))
    }

    @Test
    func `all flags are distinct`() {
        let shared = Memory.Map.Options.shared
        let priv = Memory.Map.Options.private
        let anon = Memory.Map.Options.anonymous
        let fixed = Memory.Map.Options.fixed

        let flags = [shared, priv, anon, fixed]
        let rawValues = flags.map(\.rawValue)
        let uniqueRawValues = Set(rawValues)

        #expect(uniqueRawValues.count == flags.count)
    }
}
