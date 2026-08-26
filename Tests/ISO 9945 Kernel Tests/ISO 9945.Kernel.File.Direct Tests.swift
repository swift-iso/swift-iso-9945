import Error
import ISO_9945_Kernel_Test_Support
import Path
import Tagged_Standard_Library_Integration
import Testing

@testable import ISO_9945_Kernel

extension ISO_9945.Kernel.File.Direct {
    @Suite
    struct Test {
        @Suite struct Unit {}
        @Suite struct EdgeCase {}
    }
}

extension ISO_9945.Kernel.File.Direct.Test.Unit {
    @Test
    func `Direct namespace exists`() {
        _ = ISO_9945.Kernel.File.Direct.self
    }

    @Test
    func `Direct is an enum`() {
        let _: ISO_9945.Kernel.File.Direct.Type = ISO_9945.Kernel.File.Direct.self
    }
}

extension ISO_9945.Kernel.File.Direct.Test.Unit {
    @Test
    func `Direct.Capability type exists`() {
        let _: ISO_9945.Kernel.File.Direct.Capability.Type = ISO_9945.Kernel.File.Direct.Capability
            .self
    }

    @Test
    func `Direct.Mode type exists`() {
        let _: ISO_9945.Kernel.File.Direct.Mode.Type = ISO_9945.Kernel.File.Direct.Mode.self
    }

    @Test
    func `Direct.Requirements type exists`() {
        let _: ISO_9945.Kernel.File.Direct.Requirements.Type = ISO_9945.Kernel.File.Direct
            .Requirements.self
    }

    @Test
    func `Direct.Error type exists`() {
        let _: ISO_9945.Kernel.File.Direct.Error.Type = ISO_9945.Kernel.File.Direct.Error.self
    }
}

extension ISO_9945.Kernel.File.Direct.Test.Unit {
    @Test
    func `direct mode resolved is equatable`() {
        #expect(ISO_9945.Kernel.File.Direct.Mode.Resolved.buffered == .buffered)
        #expect(ISO_9945.Kernel.File.Direct.Mode.Resolved.direct == .direct)
        #expect(ISO_9945.Kernel.File.Direct.Mode.Resolved.uncached == .uncached)
        #expect(ISO_9945.Kernel.File.Direct.Mode.Resolved.buffered != .direct)
    }

    @Test
    func `requirements known case`() {
        let alignment = ISO_9945.Kernel.File.Direct.Requirements.Alignment(uniform: .`4096`)
        let requirements = ISO_9945.Kernel.File.Direct.Requirements.known(alignment)

        if case .known(let a) = requirements {
            #expect(a.bufferAlignment == .`4096`)
        } else {
            Issue.record("Expected .known case")
        }
    }

    @Test
    func `requirements unknown case`() {
        let requirements = ISO_9945.Kernel.File.Direct.Requirements.unknown(
            reason: .platformUnsupported
        )

        if case .unknown(let reason) = requirements {
            #expect(reason == .platformUnsupported)
        } else {
            Issue.record("Expected .unknown case")
        }
    }
}
