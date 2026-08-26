import ISO_9945_Kernel
import Tagged_Standard_Library_Integration
import Testing

extension ISO_9945.Kernel.IO.Blocking.Error {
    @Suite
    struct Test {
        @Suite struct Unit {}
        @Suite struct EdgeCase {}
    }
}

extension ISO_9945.Kernel.IO.Blocking.Error.Test.Unit {
    @Test
    func `wouldBlock case exists`() {
        let error = ISO_9945.Kernel.IO.Blocking.Error.wouldBlock
        if case .wouldBlock = error {

        } else {
            Issue.record("Expected .wouldBlock case")
        }
    }
}

extension ISO_9945.Kernel.IO.Blocking.Error.Test.Unit {
    @Test
    func `wouldBlock description`() {
        let error = ISO_9945.Kernel.IO.Blocking.Error.wouldBlock
        #expect(error.description == "operation would block")
    }
}

extension ISO_9945.Kernel.IO.Blocking.Error.Test.Unit {
    @Test
    func `Error conforms to Swift.Error`() {
        let error: any Swift.Error = ISO_9945.Kernel.IO.Blocking.Error.wouldBlock
        #expect(error is ISO_9945.Kernel.IO.Blocking.Error)
    }

    @Test
    func `Error is Sendable`() {
        let error: any Sendable = ISO_9945.Kernel.IO.Blocking.Error.wouldBlock
        #expect(error is ISO_9945.Kernel.IO.Blocking.Error)
    }

    @Test
    func `Error is Equatable`() {
        let a = ISO_9945.Kernel.IO.Blocking.Error.wouldBlock
        let b = ISO_9945.Kernel.IO.Blocking.Error.wouldBlock
        #expect(a == b)
    }

    @Test
    func `Error is Hashable`() {
        var set = Set<ISO_9945.Kernel.IO.Blocking.Error>()
        set.insert(.wouldBlock)
        set.insert(.wouldBlock)
        #expect(set.count == 1)
    }
}
