@_spi(Syscall) import Error
import ISO_9945_Kernel_Test_Support
@_spi(Syscall) import Path
import Tagged_Standard_Library_Integration
import Testing

@testable import ISO_9945_Kernel

extension ISO_9945.Kernel.Close {
    @Suite
    struct Test {
        @Suite struct Unit {}
        @Suite struct EdgeCase {}
    }
}

extension ISO_9945.Kernel.Close.Test.Unit {
    @Test
    func `close succeeds on valid descriptor`() throws {
        let path = KernelIOTest.makeTempPath(prefix: "close-test")
        defer { KernelIOTest.cleanup(path: path) }
        let fd = try KernelIOTest.open(at: path)

        try ISO_9945.Kernel.Close.close(fd)
    }

    @Test
    func `close throws on invalid descriptor`() {
        #expect(throws: ISO_9945.Kernel.Close.Error.self) {
            try ISO_9945.Kernel.Close.close(.invalid)
        }
    }
}

extension ISO_9945.Kernel.Close.Test.EdgeCase {
    @Test
    func `close throws on negative descriptor`() {
        #expect(throws: ISO_9945.Kernel.Close.Error.self) {
            try ISO_9945.Kernel.Close.close(ISO_9945.Kernel.Descriptor(_raw: -100))
        }
    }
}
