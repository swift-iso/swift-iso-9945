@_spi(Syscall) import Error
import ISO_9945_Kernel_Test_Support
@_spi(Syscall) import Path
import Tagged_Standard_Library_Integration
import Terminal
import Testing

@testable import ISO_9945_Kernel

extension Terminal.Stream.Read {
    @Suite
    struct Test {
        @Suite struct Unit {}
        @Suite struct `Edge Case` {}
        @Suite struct Integration {}
        @Suite(.serialized) struct Performance {}
    }
}

extension Terminal.Stream.Read.Test.Integration {
    @Test(
        .disabled(
            "pending: stdin redirection needs non-owning descriptor API or child-process harness"
        )
    )
    func `Read bytes from pipe via stdin redirect`() throws {

    }

    @Test
    func `Read returns 0 on EOF when write end closed`() throws {
        let descriptors = try ISO_9945.Kernel.Pipe.pipe()

        let readEnd = try ISO_9945.Kernel.Pipe.Close.write(descriptors)

        var buffer = [UInt8](repeating: 0, count: 16)
        let bytesRead = try buffer.withUnsafeMutableBytes { ptr in
            try ISO_9945.Kernel.IO.Read.read(readEnd, into: ptr)
        }

        #expect(bytesRead == 0)

    }

    @Test(
        .disabled(
            "pending: stdin redirection needs non-owning descriptor API or child-process harness"
        )
    )
    func `Read escape sequence bytes from pipe`() throws {

    }

    @Test(
        .disabled(
            "pending: stdin redirection needs non-owning descriptor API or child-process harness"
        )
    )
    func `Read multiple bytes preserves order`() throws {

    }
}
