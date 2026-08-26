import ISO_9945_Kernel
import Tagged_Standard_Library_Integration
import Testing

extension ISO_9945.Kernel.File.Clone.Capability {
    @Suite
    struct Test {
        @Suite struct Unit {}
        @Suite struct EdgeCase {}
    }
}

extension ISO_9945.Kernel.File.Clone.Capability.Test.Unit {
    @Test
    func `reflink case exists`() {
        let capability = ISO_9945.Kernel.File.Clone.Capability.reflink
        if case .reflink = capability {

        } else {
            Issue.record("Expected .reflink case")
        }
    }

    @Test
    func `none case exists`() {
        let capability = ISO_9945.Kernel.File.Clone.Capability.none
        if case .none = capability {

        } else {
            Issue.record("Expected .none case")
        }
    }
}

extension ISO_9945.Kernel.File.Clone.Capability.Test.Unit {
    @Test
    func `Capability is Sendable`() {
        let capability: any Sendable = ISO_9945.Kernel.File.Clone.Capability.reflink
        #expect(capability is ISO_9945.Kernel.File.Clone.Capability)
    }

    @Test
    func `Capability is Equatable`() {
        let a = ISO_9945.Kernel.File.Clone.Capability.reflink
        let b = ISO_9945.Kernel.File.Clone.Capability.reflink
        let c = ISO_9945.Kernel.File.Clone.Capability.none
        #expect(a == b)
        #expect(a != c)
    }
}

extension ISO_9945.Kernel.File.Clone.Capability.Test.EdgeCase {
    @Test
    func `reflink and none are distinct`() {
        let reflink = ISO_9945.Kernel.File.Clone.Capability.reflink
        let none = ISO_9945.Kernel.File.Clone.Capability.none
        #expect(reflink != none)
    }

    @Test
    func `all cases are distinct`() {
        let cases: [ISO_9945.Kernel.File.Clone.Capability] = [
            .reflink,
            .none,
        ]

        for i in 0..<cases.count {
            for j in (i + 1)..<cases.count {
                #expect(cases[i] != cases[j])
            }
        }
    }
}
