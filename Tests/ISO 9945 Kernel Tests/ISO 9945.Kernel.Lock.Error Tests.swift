import ISO_9945_Kernel
import Tagged_Primitives_Standard_Library_Integration
import Testing

extension ISO_9945.Kernel.Lock.Error {
    @Suite
    struct Test {
        @Suite struct Unit {}
        @Suite struct EdgeCase {}
    }
}

extension ISO_9945.Kernel.Lock.Error.Test.Unit {
    @Test
    func `contention case exists`() {
        let error = ISO_9945.Kernel.Lock.Error.contention
        if case .contention = error {

        } else {
            Issue.record("Expected .contention case")
        }
    }

    @Test
    func `deadlock case exists`() {
        let error = ISO_9945.Kernel.Lock.Error.deadlock
        if case .deadlock = error {

        } else {
            Issue.record("Expected .deadlock case")
        }
    }

    @Test
    func `unavailable case exists`() {
        let error = ISO_9945.Kernel.Lock.Error.unavailable
        if case .unavailable = error {

        } else {
            Issue.record("Expected .unavailable case")
        }
    }
}

extension ISO_9945.Kernel.Lock.Error.Test.Unit {
    @Test
    func `timedOut is distinct from contention`() {
        #expect(ISO_9945.Kernel.Lock.Error.timedOut != ISO_9945.Kernel.Lock.Error.contention)
    }

    @Test
    func `interrupted is distinct from contention`() {
        #expect(ISO_9945.Kernel.Lock.Error.interrupted != ISO_9945.Kernel.Lock.Error.contention)
    }
}

extension ISO_9945.Kernel.Lock.Error.Test.Unit {
    @Test
    func `contention description`() {
        let error = ISO_9945.Kernel.Lock.Error.contention
        #expect(error.description == "lock contention")
    }

    @Test
    func `deadlock description`() {
        let error = ISO_9945.Kernel.Lock.Error.deadlock
        #expect(error.description == "deadlock detected")
    }

    @Test
    func `unavailable description`() {
        let error = ISO_9945.Kernel.Lock.Error.unavailable
        #expect(error.description == "no locks available")
    }
}

extension ISO_9945.Kernel.Lock.Error.Test.Unit {
    @Test
    func `Error conforms to Swift.Error`() {
        let error: any Swift.Error = ISO_9945.Kernel.Lock.Error.contention
        #expect(error is ISO_9945.Kernel.Lock.Error)
    }

    @Test
    func `Error is Sendable`() {
        let error: any Sendable = ISO_9945.Kernel.Lock.Error.contention
        #expect(error is ISO_9945.Kernel.Lock.Error)
    }

    @Test
    func `Error is Equatable`() {
        let a = ISO_9945.Kernel.Lock.Error.contention
        let b = ISO_9945.Kernel.Lock.Error.contention
        let c = ISO_9945.Kernel.Lock.Error.deadlock
        #expect(a == b)
        #expect(a != c)
    }

    @Test
    func `Error is Hashable`() {
        var set = Set<ISO_9945.Kernel.Lock.Error>()
        set.insert(.contention)
        set.insert(.deadlock)
        set.insert(.unavailable)
        set.insert(.contention)
        #expect(set.count == 3)
    }

    @Test
    func `Error is CustomStringConvertible`() {
        let error: any CustomStringConvertible = ISO_9945.Kernel.Lock.Error.contention
        #expect(!error.description.isEmpty)
    }
}

extension ISO_9945.Kernel.Lock.Error.Test.EdgeCase {
    @Test
    func `all cases are distinct`() {
        let cases: [ISO_9945.Kernel.Lock.Error] = [
            .contention,
            .deadlock,
            .unavailable,
            .timedOut,
            .interrupted,
        ]

        for i in 0..<cases.count {
            for j in (i + 1)..<cases.count {
                #expect(cases[i] != cases[j])
            }
        }
    }

    @Test
    func `all descriptions are non-empty`() {
        let cases: [ISO_9945.Kernel.Lock.Error] = [
            .contention,
            .deadlock,
            .unavailable,
            .timedOut,
            .interrupted,
        ]

        for error in cases {
            #expect(!error.description.isEmpty)
        }
    }

    @Test
    func `all descriptions are unique`() {
        let descriptions = [
            ISO_9945.Kernel.Lock.Error.contention.description,
            ISO_9945.Kernel.Lock.Error.deadlock.description,
            ISO_9945.Kernel.Lock.Error.unavailable.description,
            ISO_9945.Kernel.Lock.Error.timedOut.description,
            ISO_9945.Kernel.Lock.Error.interrupted.description,
        ]

        let unique = Set(descriptions)
        #expect(unique.count == descriptions.count)
    }

    @Test
    func `hash values for different errors are different`() {
        let contentionHash = ISO_9945.Kernel.Lock.Error.contention.hashValue
        let deadlockHash = ISO_9945.Kernel.Lock.Error.deadlock.hashValue
        let unavailableHash = ISO_9945.Kernel.Lock.Error.unavailable.hashValue

        #expect(contentionHash != deadlockHash || deadlockHash != unavailableHash)
    }
}
