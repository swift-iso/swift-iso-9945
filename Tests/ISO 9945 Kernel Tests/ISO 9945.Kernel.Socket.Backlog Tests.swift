import Error
import ISO_9945_Kernel_Test_Support
import Path
import Tagged_Standard_Library_Integration
import Testing

@testable import ISO_9945_Kernel

extension ISO_9945.Kernel.Socket.Backlog {
    @Suite
    struct Test {
        @Suite struct Unit {}
        @Suite struct EdgeCase {}
    }
}

extension ISO_9945.Kernel.Socket.Backlog.Test.Unit {
    @Test
    func `Backlog type exists`() {
        let _: ISO_9945.Kernel.Socket.Backlog.Type = ISO_9945.Kernel.Socket.Backlog.self
    }

    @Test
    func `Backlog from rawValue`() {
        let backlog = ISO_9945.Kernel.Socket.Backlog(rawValue: 64)
        #expect(backlog.rawValue == 64)
    }

    @Test
    func `Backlog from Int32`() {
        let backlog = ISO_9945.Kernel.Socket.Backlog(256)
        #expect(backlog.rawValue == 256)
    }
}

extension ISO_9945.Kernel.Socket.Backlog.Test.Unit {
    @Test
    func `Backlog.default is 128`() {
        #expect(ISO_9945.Kernel.Socket.Backlog.default.rawValue == 128)
    }

    @Test
    func `Backlog.small is 16`() {
        #expect(ISO_9945.Kernel.Socket.Backlog.small.rawValue == 16)
    }

    @Test
    func `Backlog.large is 4096`() {
        #expect(ISO_9945.Kernel.Socket.Backlog.large.rawValue == 4096)
    }

    @Test
    func `Backlog.max uses SOMAXCONN`() {
        let max = ISO_9945.Kernel.Socket.Backlog.max
        #expect(max.rawValue > 0)
    }
}

extension ISO_9945.Kernel.Socket.Backlog.Test.Unit {
    @Test
    func `Backlog from integer literal`() {
        let backlog: ISO_9945.Kernel.Socket.Backlog = 512
        #expect(backlog.rawValue == 512)
    }
}

extension ISO_9945.Kernel.Socket.Backlog.Test.Unit {
    @Test
    func `Backlog is Sendable`() {
        let value: any Sendable = ISO_9945.Kernel.Socket.Backlog.default
        #expect(value is ISO_9945.Kernel.Socket.Backlog)
    }

    @Test
    func `Backlog is Equatable`() {
        let a = ISO_9945.Kernel.Socket.Backlog(128)
        let b = ISO_9945.Kernel.Socket.Backlog(128)
        let c = ISO_9945.Kernel.Socket.Backlog(256)
        #expect(a == b)
        #expect(a != c)
    }

    @Test
    func `Backlog is Hashable`() {
        var set = Set<ISO_9945.Kernel.Socket.Backlog>()
        set.insert(.default)
        set.insert(.small)
        set.insert(.default)
        #expect(set.count == 2)
    }
}

extension ISO_9945.Kernel.Socket.Backlog.Test.Unit {
    @Test
    func `Backlog description shows raw value`() {
        let backlog = ISO_9945.Kernel.Socket.Backlog(100)
        #expect(backlog.description == "100")
    }
}

extension ISO_9945.Kernel.Socket.Backlog.Test.EdgeCase {
    @Test
    func `Backlog zero`() {
        let backlog = ISO_9945.Kernel.Socket.Backlog(0)
        #expect(backlog.rawValue == 0)
    }

    @Test
    func `Backlog negative`() {
        let backlog = ISO_9945.Kernel.Socket.Backlog(-1)
        #expect(backlog.rawValue == -1)
    }

    @Test
    func `Backlog rawValue roundtrip`() {
        for value: Int32 in [0, 1, 16, 128, 4096, Int32.max] {
            let backlog = ISO_9945.Kernel.Socket.Backlog(rawValue: value)
            #expect(backlog.rawValue == value)
        }
    }
}
