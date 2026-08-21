import ISO_9945_Kernel
import Tagged_Primitives_Standard_Library_Integration
import Testing

extension ISO_9945.Kernel.File.Stats.Kind.Link {
    @Suite
    struct Test {
        @Suite struct Unit {}
        @Suite struct EdgeCase {}
    }
}

extension ISO_9945.Kernel.File.Stats.Kind.Link.Test.Unit {
    @Test
    func `symbolic case exists`() {
        let link = ISO_9945.Kernel.File.Stats.Kind.Link.symbolic
        if case .symbolic = link {

        } else {
            Issue.record("Expected .symbolic case")
        }
    }

    @Test
    func `junction case exists`() {
        let link = ISO_9945.Kernel.File.Stats.Kind.Link.junction
        if case .junction = link {

        } else {
            Issue.record("Expected .junction case")
        }
    }
}

extension ISO_9945.Kernel.File.Stats.Kind.Link.Test.Unit {
    @Test
    func `Link is Sendable`() {
        let link: any Sendable = ISO_9945.Kernel.File.Stats.Kind.Link.symbolic
        #expect(link is ISO_9945.Kernel.File.Stats.Kind.Link)
    }

    @Test
    func `Link is Equatable`() {
        let a = ISO_9945.Kernel.File.Stats.Kind.Link.symbolic
        let b = ISO_9945.Kernel.File.Stats.Kind.Link.symbolic
        let c = ISO_9945.Kernel.File.Stats.Kind.Link.junction
        #expect(a == b)
        #expect(a != c)
    }

    @Test
    func `Link is Hashable`() {
        var set = Set<ISO_9945.Kernel.File.Stats.Kind.Link>()
        set.insert(.symbolic)
        set.insert(.junction)
        set.insert(.symbolic)
        #expect(set.count == 2)
    }
}

extension ISO_9945.Kernel.File.Stats.Kind.Link.Test.EdgeCase {
    @Test
    func `symbolic and junction are distinct`() {
        let symbolic = ISO_9945.Kernel.File.Stats.Kind.Link.symbolic
        let junction = ISO_9945.Kernel.File.Stats.Kind.Link.junction
        #expect(symbolic != junction)
    }
}
