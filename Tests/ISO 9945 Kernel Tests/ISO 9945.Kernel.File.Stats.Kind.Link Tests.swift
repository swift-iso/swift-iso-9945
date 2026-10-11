import ISO_9945_Kernel
import Tagged
import Testing

extension ISO_9945.Kernel.File.Stats.Kind.Link {
    @Suite
    struct Test {
        @Suite struct Unit {}
    }
}

extension ISO_9945.Kernel.File.Stats.Kind.Link.Test.Unit {
    @Test
    func `symbolic case matches`() {
        let link = ISO_9945.Kernel.File.Stats.Kind.Link.symbolic
        if case .symbolic = link {

        } else {
            Issue.record("Expected .symbolic case")
        }
    }

    @Test
    func `Link is Hashable`() {
        var set = Set<ISO_9945.Kernel.File.Stats.Kind.Link>()
        set.insert(.symbolic)
        set.insert(.symbolic)
        #expect(set.count == 1)
    }
}
