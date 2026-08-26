import ISO_9945_Kernel
import Tagged_Standard_Library_Integration
import Testing

extension ISO_9945.Kernel.File.Direct.Mode {
    @Suite
    struct Test {
        @Suite struct Unit {}
        @Suite struct EdgeCase {}
    }
}

extension ISO_9945.Kernel.File.Direct.Mode.Test.Unit {
    @Test
    func `direct case exists`() {
        let mode = ISO_9945.Kernel.File.Direct.Mode.direct
        if case .direct = mode {

        } else {
            Issue.record("Expected .direct case")
        }
    }

    @Test
    func `uncached case exists`() {
        let mode = ISO_9945.Kernel.File.Direct.Mode.uncached
        if case .uncached = mode {

        } else {
            Issue.record("Expected .uncached case")
        }
    }

    @Test
    func `buffered case exists`() {
        let mode = ISO_9945.Kernel.File.Direct.Mode.buffered
        if case .buffered = mode {

        } else {
            Issue.record("Expected .buffered case")
        }
    }

    @Test
    func `auto case exists`() {
        let mode = ISO_9945.Kernel.File.Direct.Mode.auto(policy: .fallbackToBuffered)
        if case .auto = mode {

        } else {
            Issue.record("Expected .auto case")
        }
    }
}

extension ISO_9945.Kernel.File.Direct.Mode.Test.Unit {
    @Test
    func `Mode is Sendable`() {
        let mode: any Sendable = ISO_9945.Kernel.File.Direct.Mode.buffered
        #expect(mode is ISO_9945.Kernel.File.Direct.Mode)
    }

    @Test
    func `Mode is Equatable`() {
        let a = ISO_9945.Kernel.File.Direct.Mode.buffered
        let b = ISO_9945.Kernel.File.Direct.Mode.buffered
        let c = ISO_9945.Kernel.File.Direct.Mode.direct
        #expect(a == b)
        #expect(a != c)
    }
}

extension ISO_9945.Kernel.File.Direct.Mode.Test.Unit {
    @Test
    func `Mode.Policy type exists`() {
        let _: ISO_9945.Kernel.File.Direct.Mode.Policy.Type = ISO_9945.Kernel.File.Direct.Mode
            .Policy.self
    }

    @Test
    func `Mode.Resolved type exists`() {
        let _: ISO_9945.Kernel.File.Direct.Mode.Resolved.Type = ISO_9945.Kernel.File.Direct.Mode
            .Resolved.self
    }
}

extension ISO_9945.Kernel.File.Direct.Mode.Test.EdgeCase {
    @Test
    func `all simple cases are distinct`() {
        let cases: [ISO_9945.Kernel.File.Direct.Mode] = [
            .direct,
            .uncached,
            .buffered,
        ]

        for i in 0..<cases.count {
            for j in (i + 1)..<cases.count {
                #expect(cases[i] != cases[j])
            }
        }
    }

    @Test
    func `auto with different policies are distinct`() {
        let fallback = ISO_9945.Kernel.File.Direct.Mode.auto(policy: .fallbackToBuffered)
        let error = ISO_9945.Kernel.File.Direct.Mode.auto(policy: .errorOnViolation)
        #expect(fallback != error)
    }
}
