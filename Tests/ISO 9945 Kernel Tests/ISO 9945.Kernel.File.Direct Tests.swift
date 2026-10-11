import Error
import ISO_9945_Kernel_Test_Support
import Path
import Tagged
import Testing

@testable import ISO_9945_Kernel

extension ISO_9945.Kernel.File.Direct {
    @Suite
    struct Test {
        @Suite struct Unit {}
        @Suite struct `Edge Case` {}
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
