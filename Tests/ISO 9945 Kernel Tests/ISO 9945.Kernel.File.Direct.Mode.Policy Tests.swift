import ISO_9945_Kernel
import Tagged_Standard_Library_Integration
import Testing

extension ISO_9945.Kernel.File.Direct.Mode.Policy {
    @Suite
    struct Test {
        @Suite struct Unit {}
        @Suite struct EdgeCase {}
    }
}

extension ISO_9945.Kernel.File.Direct.Mode.Policy.Test.Unit {
    @Test
    func `fallbackToBuffered case exists`() {
        let policy = ISO_9945.Kernel.File.Direct.Mode.Policy.fallbackToBuffered
        if case .fallbackToBuffered = policy {

        } else {
            Issue.record("Expected .fallbackToBuffered case")
        }
    }

    @Test
    func `errorOnViolation case exists`() {
        let policy = ISO_9945.Kernel.File.Direct.Mode.Policy.errorOnViolation
        if case .errorOnViolation = policy {

        } else {
            Issue.record("Expected .errorOnViolation case")
        }
    }
}

extension ISO_9945.Kernel.File.Direct.Mode.Policy.Test.Unit {
    @Test
    func `Policy is Sendable`() {
        let policy: any Sendable = ISO_9945.Kernel.File.Direct.Mode.Policy.fallbackToBuffered
        #expect(policy is ISO_9945.Kernel.File.Direct.Mode.Policy)
    }

    @Test
    func `Policy is Equatable`() {
        let a = ISO_9945.Kernel.File.Direct.Mode.Policy.fallbackToBuffered
        let b = ISO_9945.Kernel.File.Direct.Mode.Policy.fallbackToBuffered
        let c = ISO_9945.Kernel.File.Direct.Mode.Policy.errorOnViolation
        #expect(a == b)
        #expect(a != c)
    }
}

extension ISO_9945.Kernel.File.Direct.Mode.Policy.Test.EdgeCase {
    @Test
    func `all policies are distinct`() {
        let fallback = ISO_9945.Kernel.File.Direct.Mode.Policy.fallbackToBuffered
        let error = ISO_9945.Kernel.File.Direct.Mode.Policy.errorOnViolation
        #expect(fallback != error)
    }
}
