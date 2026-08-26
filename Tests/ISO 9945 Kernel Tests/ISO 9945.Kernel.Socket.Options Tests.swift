import Error
import ISO_9945_Kernel_Test_Support
import Path
import Tagged_Standard_Library_Integration
import Testing

@testable import ISO_9945_Kernel

#if canImport(Darwin)
    import Darwin
#elseif canImport(Glibc)
    import Glibc
#elseif canImport(Musl)
    import Musl
#endif

extension ISO_9945.Kernel.Socket.Options {
    @Suite
    struct Test {
        @Suite struct Unit {}
        @Suite struct EdgeCase {}
    }
}

extension ISO_9945.Kernel.Socket.Options.Test.Unit {
    @Test
    func `Options type exists`() {
        let _: ISO_9945.Kernel.Socket.Options.Type = ISO_9945.Kernel.Socket.Options.self
    }

    @Test
    func `Options from rawValue`() {
        let flags = ISO_9945.Kernel.Socket.Options(rawValue: O_NONBLOCK)
        #expect(flags.rawValue == O_NONBLOCK)
    }
}

extension ISO_9945.Kernel.Socket.Options.Test.Unit {
    @Test
    func `nonBlock flag`() {
        let flags = ISO_9945.Kernel.Socket.Options.nonBlock
        #expect(flags.rawValue == O_NONBLOCK)
    }

    @Test
    func `closeOnExec flag`() {
        let flags = ISO_9945.Kernel.Socket.Options.closeOnExec
        #expect(flags.rawValue == O_CLOEXEC)
    }

    @Test
    func `none flag is empty`() {
        let flags = ISO_9945.Kernel.Socket.Options.none
        #expect(flags.isEmpty)
        #expect(flags.rawValue == 0)
    }

    @Test
    func `asyncDefault combines nonBlock and closeOnExec`() {
        let flags = ISO_9945.Kernel.Socket.Options.asyncDefault
        #expect(flags.contains(.nonBlock))
        #expect(flags.contains(.closeOnExec))
    }
}

extension ISO_9945.Kernel.Socket.Options.Test.Unit {
    @Test
    func `Options can be combined with array literal`() {
        let combined: ISO_9945.Kernel.Socket.Options = [.nonBlock, .closeOnExec]
        #expect(combined.contains(.nonBlock))
        #expect(combined.contains(.closeOnExec))
    }

    @Test
    func `Options contains check`() {
        let flags: ISO_9945.Kernel.Socket.Options = [.nonBlock, .closeOnExec]
        #expect(flags.contains(.nonBlock))
        #expect(flags.contains(.closeOnExec))
    }

    @Test
    func `Options array literal initialization`() {
        let flags: ISO_9945.Kernel.Socket.Options = [.nonBlock, .closeOnExec]
        #expect(flags == .asyncDefault)
    }
}

extension ISO_9945.Kernel.Socket.Options.Test.Unit {
    @Test
    func `Options is Sendable`() {
        let value: any Sendable = ISO_9945.Kernel.Socket.Options.none
        #expect(value is ISO_9945.Kernel.Socket.Options)
    }

    @Test
    func `Options is Equatable`() {
        let a = ISO_9945.Kernel.Socket.Options.nonBlock
        let b = ISO_9945.Kernel.Socket.Options.nonBlock
        let c = ISO_9945.Kernel.Socket.Options.closeOnExec
        #expect(a == b)
        #expect(a != c)
    }
}

extension ISO_9945.Kernel.Socket.Options.Test.EdgeCase {
    @Test
    func `Empty flags is none`() {
        let empty: ISO_9945.Kernel.Socket.Options = []
        #expect(empty == .none)
    }

    @Test
    func `Options rawValue roundtrip`() {
        let original: ISO_9945.Kernel.Socket.Options = [.nonBlock, .closeOnExec]
        let roundtrip = ISO_9945.Kernel.Socket.Options(rawValue: original.rawValue)
        #expect(roundtrip == original)
    }
}
