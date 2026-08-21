import Error_Primitives
import ISO_9945_Kernel_Test_Support
import Path_Primitives
import Tagged_Primitives_Standard_Library_Integration
import Testing

@testable import ISO_9945_Kernel

extension ISO_9945.Kernel.File.Seek.Origin {
    @Suite
    struct Test {
        @Suite struct Unit {}
        @Suite struct EdgeCase {}
    }
}

extension ISO_9945.Kernel.File.Seek.Origin.Test.Unit {
    @Test
    func `start case exists`() {
        let origin = ISO_9945.Kernel.File.Seek.Origin.start
        if case .start = origin {

        } else {
            Issue.record("Expected .start case")
        }
    }

    @Test
    func `current case exists`() {
        let origin = ISO_9945.Kernel.File.Seek.Origin.current
        if case .current = origin {

        } else {
            Issue.record("Expected .current case")
        }
    }

    @Test
    func `end case exists`() {
        let origin = ISO_9945.Kernel.File.Seek.Origin.end
        if case .end = origin {

        } else {
            Issue.record("Expected .end case")
        }
    }
}

extension ISO_9945.Kernel.File.Seek.Origin.Test.Unit {
    @Test
    func `Origin is Sendable`() {
        let origin: any Sendable = ISO_9945.Kernel.File.Seek.Origin.start
        #expect(origin is ISO_9945.Kernel.File.Seek.Origin)
    }
}

extension ISO_9945.Kernel.File.Seek.Origin.Test.EdgeCase {
    @Test
    func `all cases are distinct`() {
        let start = ISO_9945.Kernel.File.Seek.Origin.start
        let current = ISO_9945.Kernel.File.Seek.Origin.current
        let end = ISO_9945.Kernel.File.Seek.Origin.end

        switch start {
        case .start:
            break

        case .current, .end:
            Issue.record("start should not match current or end")
        }

        switch current {
        case .current:
            break

        case .start, .end:
            Issue.record("current should not match start or end")
        }

        switch end {
        case .end:
            break

        case .start, .current:
            Issue.record("end should not match start or current")
        }
    }
}

extension ISO_9945.Kernel.File.Seek.Origin.Test.Unit {
    @Test
    func `Origin can be used in switch`() {
        func describe(_ origin: ISO_9945.Kernel.File.Seek.Origin) -> Swift.String {
            switch origin {
            case .start: return "beginning"
            case .current: return "current position"
            case .end: return "end"
            }
        }

        #expect(describe(.start) == "beginning")
        #expect(describe(.current) == "current position")
        #expect(describe(.end) == "end")
    }
}
