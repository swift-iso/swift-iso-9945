import ISO_9945_Kernel
import Tagged_Primitives_Standard_Library_Integration
import Testing

extension ISO_9945.Kernel.Lock.Kind {
    @Suite
    struct Test {
        @Suite struct Unit {}
        @Suite struct EdgeCase {}
    }
}

extension ISO_9945.Kernel.Lock.Kind.Test.Unit {
    @Test
    func `shared case exists`() {
        let kind = ISO_9945.Kernel.Lock.Kind.shared
        if case .shared = kind {

        } else {
            Issue.record("Expected .shared case")
        }
    }

    @Test
    func `exclusive case exists`() {
        let kind = ISO_9945.Kernel.Lock.Kind.exclusive
        if case .exclusive = kind {

        } else {
            Issue.record("Expected .exclusive case")
        }
    }
}

extension ISO_9945.Kernel.Lock.Kind.Test.Unit {
    @Test
    func `Kind is Sendable`() {
        let kind: any Sendable = ISO_9945.Kernel.Lock.Kind.shared
        #expect(kind is ISO_9945.Kernel.Lock.Kind)
    }

    @Test
    func `Kind is Equatable`() {
        let a = ISO_9945.Kernel.Lock.Kind.shared
        let b = ISO_9945.Kernel.Lock.Kind.shared
        let c = ISO_9945.Kernel.Lock.Kind.exclusive
        #expect(a == b)
        #expect(a != c)
    }

    @Test
    func `Kind is Hashable`() {
        var set = Set<ISO_9945.Kernel.Lock.Kind>()
        set.insert(.shared)
        set.insert(.exclusive)
        set.insert(.shared)
        #expect(set.count == 2)
    }
}

extension ISO_9945.Kernel.Lock.Kind.Test.EdgeCase {
    @Test
    func `shared and exclusive are distinct`() {
        let shared = ISO_9945.Kernel.Lock.Kind.shared
        let exclusive = ISO_9945.Kernel.Lock.Kind.exclusive
        #expect(shared != exclusive)
    }

    @Test
    func `hash values for different kinds are different`() {
        let sharedHash = ISO_9945.Kernel.Lock.Kind.shared.hashValue
        let exclusiveHash = ISO_9945.Kernel.Lock.Kind.exclusive.hashValue
        #expect(sharedHash != exclusiveHash)
    }
}
