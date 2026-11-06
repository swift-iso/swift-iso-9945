import ISO_9945_Kernel
import Tagged
import Testing

enum `ISO_9945.Kernel.File.Stats.Kind.Link Tests` {}

extension `ISO_9945.Kernel.File.Stats.Kind.Link Tests` {
    @Suite
    struct Test {
        @Suite struct Unit {}
    }
}

extension `ISO_9945.Kernel.File.Stats.Kind.Link Tests`.Test.Unit {
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
