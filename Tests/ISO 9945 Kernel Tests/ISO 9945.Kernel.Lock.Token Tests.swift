import Error_Primitives
import ISO_9945_Kernel_Test_Support
import Path_Primitives
import Tagged_Primitives_Standard_Library_Integration
import Testing

@testable import ISO_9945_Kernel

extension ISO_9945.Kernel.Lock.Token {
    @Suite
    struct Test {
        @Suite struct Unit {}
        @Suite struct EdgeCase {}
    }
}

extension ISO_9945.Kernel.Lock.Token.Test.Unit {
    @Test
    func `Token type exists`() {
        let _: ISO_9945.Kernel.Lock.Token.Type = ISO_9945.Kernel.Lock.Token.self
    }

    @Test
    func `Token is ~Copyable`() {

        let _: ISO_9945.Kernel.Lock.Token.Type = ISO_9945.Kernel.Lock.Token.self
    }
}

extension ISO_9945.Kernel.Lock.Token.Test.Unit {
    @Test
    func `withExclusive exists`() {

        typealias WithExclusiveType = (
            borrowing ISO_9945.Kernel.Descriptor,
            ISO_9945.Kernel.Lock.Range,
            ISO_9945.Kernel.Lock.Acquire,
            () throws -> Void
        ) throws -> Void

    }

    @Test
    func `withShared exists`() {

        typealias WithSharedType = (
            borrowing ISO_9945.Kernel.Descriptor,
            ISO_9945.Kernel.Lock.Range,
            ISO_9945.Kernel.Lock.Acquire,
            () throws -> Void
        ) throws -> Void

    }
}

extension ISO_9945.Kernel.Lock.Token.Test.Unit {
    @Test
    func `Token init accepts try acquisition`() {

        let _: ISO_9945.Kernel.Lock.Acquire = .try
    }

    @Test
    func `Token init accepts wait acquisition`() {

        let _: ISO_9945.Kernel.Lock.Acquire = .wait
    }

    @Test
    func `Token init accepts deadline acquisition`() {

        let deadline = Clock.Continuous.now
        let _: ISO_9945.Kernel.Lock.Acquire = .deadline(deadline)
    }
}

extension ISO_9945.Kernel.Lock.Token.Test.Unit {
    @Test
    func `Token init has default range of .file`() {

        let _: ISO_9945.Kernel.Lock.Range = .file
    }

    @Test
    func `Token init has default acquire of .wait`() {

        let _: ISO_9945.Kernel.Lock.Acquire = .wait
    }
}

extension ISO_9945.Kernel.Lock.Token.Test.EdgeCase {
    @Test
    func `Token uses all Lock.Kind values`() {

        let _: ISO_9945.Kernel.Lock.Kind = .shared
        let _: ISO_9945.Kernel.Lock.Kind = .exclusive
    }

    @Test
    func `Token uses all Lock.Range values`() {

        let _: ISO_9945.Kernel.Lock.Range = .file
        let _: ISO_9945.Kernel.Lock.Range = .bytes(start: 0, end: 100)
        let _: ISO_9945.Kernel.Lock.Range = .bytes(start: 0, length: 100)
    }

    @Test
    func `Token uses all Lock.Acquire values`() {

        let _: ISO_9945.Kernel.Lock.Acquire = .try
        let _: ISO_9945.Kernel.Lock.Acquire = .wait
        let _: ISO_9945.Kernel.Lock.Acquire = .deadline(Clock.Continuous.now)
    }
}
