@_spi(Syscall) import Error
import ISO_9945_Kernel_Test_Support
@_spi(Syscall) import Path
import Tagged_Standard_Library_Integration
import Testing

@testable @_spi(Syscall) import ISO_9945_Kernel

extension ISO_9945.Kernel.Descriptor {
    @Suite
    struct Test {
        @Suite struct Unit {}
        @Suite struct EdgeCase {}
    }
}

extension ISO_9945.Kernel.Descriptor.Test.Unit {
    @Test
    func `invalid descriptor has correct raw value on POSIX`() {
        let invalidFd = ISO_9945.Kernel.Descriptor.invalid._rawValue
        #expect(invalidFd == -1)
    }

    @Test
    func `isValid returns false for invalid descriptor`() {
        let isValid = ISO_9945.Kernel.Descriptor.invalid.isValid
        #expect(!isValid)
    }

    @Test
    func `isValid returns true for valid descriptor`() throws {

        let path = KernelIOTest.makeTempPath(prefix: "valid-fd-test")
        defer { KernelIOTest.cleanup(path: path) }
        let fd = try KernelIOTest.open(at: path)
        let fdIsValid = fd.isValid
        #expect(fdIsValid)
    }

    @Test
    func `negative descriptors are invalid on POSIX`() {
        let minusOne = ISO_9945.Kernel.Descriptor(_raw: -1).isValid
        let minusHundred = ISO_9945.Kernel.Descriptor(_raw: -100).isValid
        let intMin = ISO_9945.Kernel.Descriptor(_raw: Int32.min).isValid
        #expect(!minusOne)
        #expect(!minusHundred)
        #expect(!intMin)
    }
}
