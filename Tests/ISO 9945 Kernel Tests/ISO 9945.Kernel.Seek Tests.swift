import Error
import ISO_9945_Kernel_Test_Support
import Path
import Tagged_Standard_Library_Integration
import Testing

@testable import ISO_9945_Kernel

extension ISO_9945.Kernel.File.Seek {
    @Suite
    struct Test {
        @Suite struct Unit {}
        @Suite struct EdgeCase {}
    }
}

extension ISO_9945.Kernel.File.Seek.Test.Unit {
    @Test
    func `Origin cases are distinct`() {
        let start = ISO_9945.Kernel.File.Seek.Origin.start
        let current = ISO_9945.Kernel.File.Seek.Origin.current
        let end = ISO_9945.Kernel.File.Seek.Origin.end

        #expect(start != current)
        #expect(start != end)
        #expect(current != end)
    }

    @Test
    func `Origin is Sendable`() {
        let origin: any Sendable = ISO_9945.Kernel.File.Seek.Origin.start
        #expect(origin is ISO_9945.Kernel.File.Seek.Origin)
    }
}
