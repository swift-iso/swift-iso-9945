import ISO_9945_Kernel
import Tagged_Standard_Library_Integration
import Testing

extension ISO_9945.Kernel.File.Stats.Error {
    @Suite
    struct Test {
        @Suite struct Unit {}
        @Suite struct EdgeCase {}
    }
}

extension ISO_9945.Kernel.File.Stats.Error.Test.Unit {
    @Test
    func `handle case stores Descriptor.Validity.Error`() {
        let handleError = ISO_9945.Kernel.Descriptor.Validity.Error.invalid
        let error = ISO_9945.Kernel.File.Stats.Error.handle(handleError)
        if case .handle(let stored) = error {
            #expect(stored == handleError)
        } else {
            Issue.record("Expected .handle case")
        }
    }

    @Test
    func `platform case stores Error.Error`() {
        let code = Error.Error.Code.posix(999)
        let unmappedError = Error.Error(code: code)
        let error = ISO_9945.Kernel.File.Stats.Error.platform(unmappedError)
        if case .platform(let stored) = error {
            #expect(stored == unmappedError)
        } else {
            Issue.record("Expected .platform case")
        }
    }
}

extension ISO_9945.Kernel.File.Stats.Error.Test.Unit {
    @Test
    func `handle description format`() {
        let error = ISO_9945.Kernel.File.Stats.Error.handle(.invalid)
        #expect(error.description.contains("handle:"))
    }

}

extension ISO_9945.Kernel.File.Stats.Error.Test.Unit {
    @Test
    func `Error conforms to Swift.Error`() {
        let error: any Swift.Error = ISO_9945.Kernel.File.Stats.Error.handle(.invalid)
        #expect(error is ISO_9945.Kernel.File.Stats.Error)
    }

    @Test
    func `Error is Sendable`() {
        let error: any Sendable = ISO_9945.Kernel.File.Stats.Error.handle(.invalid)
        #expect(error is ISO_9945.Kernel.File.Stats.Error)
    }

    @Test
    func `Error is Equatable`() {
        let a = ISO_9945.Kernel.File.Stats.Error.handle(.invalid)
        let b = ISO_9945.Kernel.File.Stats.Error.handle(.invalid)
        let c = ISO_9945.Kernel.File.Stats.Error.platform(Error.Error(code: .posix(2)))
        #expect(a == b)
        #expect(a != c)
    }
}

extension ISO_9945.Kernel.File.Stats.Error.Test.EdgeCase {
    @Test
    func `all cases are distinct`() {
        let cases: [ISO_9945.Kernel.File.Stats.Error] = [
            .handle(.invalid),
            .platform(Error.Error(code: .posix(1))),
        ]

        for i in 0..<cases.count {
            for j in (i + 1)..<cases.count {
                #expect(cases[i] != cases[j])
            }
        }
    }

    @Test
    func `handle invalid vs limit are distinct`() {
        let invalid = ISO_9945.Kernel.File.Stats.Error.handle(.invalid)
        let processLimit = ISO_9945.Kernel.File.Stats.Error.handle(.limit(.process))
        let systemLimit = ISO_9945.Kernel.File.Stats.Error.handle(.limit(.system))
        #expect(invalid != processLimit)
        #expect(processLimit != systemLimit)
    }

}
