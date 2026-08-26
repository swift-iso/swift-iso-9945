@_spi(Syscall) import Error
import ISO_9945_Kernel_Test_Support
@_spi(Syscall) import Path
import Tagged_Standard_Library_Integration
import Testing

@testable import ISO_9945_Kernel

extension ISO_9945.Kernel.IO.Read {
    @Suite
    struct Test {
        @Suite struct Unit {}
        @Suite struct EdgeCase {}
    }
}

extension ISO_9945.Kernel.IO.Read.Test.Unit {
    @Test
    func `OutputSpan overload has the synchronous typed signature`() {
        let read:
            (borrowing ISO_9945.Kernel.Descriptor, inout Swift.OutputSpan<Byte>) throws(ISO_9945
                .Kernel.IO.Read.Error) -> Int = ISO_9945.Kernel.IO.Read.read
        _ = read
    }

    @Test
    func `read returns bytes from file`() throws {
        let path = KernelIOTest.makeTempPath(prefix: "read-test")
        let fd = try KernelIOTest.open(at: path)
        defer { KernelIOTest.cleanup(path: path) }
        KernelIOTest.write("Hello, World!", to: fd)

        _ = try ISO_9945.Kernel.File.Seek.seek(fd, offset: 0, whence: .start)

        var buffer = [UInt8](repeating: 0, count: 13)
        let bytesRead = try buffer.withUnsafeMutableBytes { ptr in
            try ISO_9945.Kernel.IO.Read.read(fd, into: ptr)
        }

        #expect(bytesRead == 13)
        #expect(Swift.String(decoding: buffer, as: UTF8.self) == "Hello, World!")
    }

    @Test
    func `read returns 0 on EOF`() throws {
        let path = KernelIOTest.makeTempPath(prefix: "read-test")
        let fd = try KernelIOTest.open(at: path)
        defer { KernelIOTest.cleanup(path: path) }
        KernelIOTest.write("Hi", to: fd)

        _ = try ISO_9945.Kernel.File.Seek.seek(fd, offset: 0, whence: .start)
        var buffer = [UInt8](repeating: 0, count: 10)
        _ = try buffer.withUnsafeMutableBytes { ptr in
            try ISO_9945.Kernel.IO.Read.read(fd, into: ptr)
        }

        let bytesRead = try buffer.withUnsafeMutableBytes { ptr in
            try ISO_9945.Kernel.IO.Read.read(fd, into: ptr)
        }

        #expect(bytesRead == 0)
    }

    @Test
    func `read with empty buffer returns 0`() throws {
        let path = KernelIOTest.makeTempPath(prefix: "read-test")
        let fd = try KernelIOTest.open(at: path)
        defer { KernelIOTest.cleanup(path: path) }
        KernelIOTest.write("content", to: fd)

        let emptyBuffer = UnsafeMutableRawBufferPointer(start: nil, count: 0)
        let bytesRead = try ISO_9945.Kernel.IO.Read.read(fd, into: emptyBuffer)

        #expect(bytesRead == 0)
    }

    @Test
    func `read partial buffer`() throws {
        let path = KernelIOTest.makeTempPath(prefix: "read-test")
        let fd = try KernelIOTest.open(at: path)
        defer { KernelIOTest.cleanup(path: path) }
        KernelIOTest.write("Short", to: fd)

        _ = try ISO_9945.Kernel.File.Seek.seek(fd, offset: 0, whence: .start)

        var buffer = [UInt8](repeating: 0, count: 100)
        let bytesRead = try buffer.withUnsafeMutableBytes { ptr in
            try ISO_9945.Kernel.IO.Read.read(fd, into: ptr)
        }

        #expect(bytesRead == 5)
        #expect(Swift.String(decoding: buffer.prefix(5), as: UTF8.self) == "Short")
    }

    @Test
    func `pread reads at offset without changing position`() throws {
        let path = KernelIOTest.makeTempPath(prefix: "read-test")
        let fd = try KernelIOTest.open(at: path)
        defer { KernelIOTest.cleanup(path: path) }
        KernelIOTest.write("0123456789", to: fd)

        let initialPos = try ISO_9945.Kernel.File.Seek.tell(fd)

        var buffer = [UInt8](repeating: 0, count: 3)
        let bytesRead = try buffer.withUnsafeMutableBytes { ptr in
            try ISO_9945.Kernel.IO.Read.pread(fd, into: ptr, at: ISO_9945.Kernel.File.Offset(5))
        }

        #expect(bytesRead == 3)
        #expect(Swift.String(decoding: buffer, as: UTF8.self) == "567")

        let finalPos = try ISO_9945.Kernel.File.Seek.tell(fd)
        #expect(finalPos == initialPos)
    }

    @Test
    func `pread at end of file returns 0`() throws {
        let path = KernelIOTest.makeTempPath(prefix: "read-test")
        let fd = try KernelIOTest.open(at: path)
        defer { KernelIOTest.cleanup(path: path) }
        KernelIOTest.write("data", to: fd)

        var buffer = [UInt8](repeating: 0, count: 10)
        let bytesRead = try buffer.withUnsafeMutableBytes { ptr in
            try ISO_9945.Kernel.IO.Read.pread(fd, into: ptr, at: ISO_9945.Kernel.File.Offset(100))
        }

        #expect(bytesRead == 0)
    }

    @Test
    func `pread with empty buffer returns 0`() throws {
        let path = KernelIOTest.makeTempPath(prefix: "read-test")
        let fd = try KernelIOTest.open(at: path)
        defer { KernelIOTest.cleanup(path: path) }
        KernelIOTest.write("content", to: fd)

        let emptyBuffer = UnsafeMutableRawBufferPointer(start: nil, count: 0)
        let bytesRead = try ISO_9945.Kernel.IO.Read.pread(
            fd,
            into: emptyBuffer,
            at: ISO_9945.Kernel.File.Offset(0)
        )

        #expect(bytesRead == 0)
    }
}

extension ISO_9945.Kernel.IO.Read.Test.EdgeCase {
    @Test
    func `read throws on invalid descriptor`() {
        var buffer = [UInt8](repeating: 0, count: 10)

        #expect(throws: ISO_9945.Kernel.IO.Read.Error.self) {
            try buffer.withUnsafeMutableBytes { ptr in
                try ISO_9945.Kernel.IO.Read.read(ISO_9945.Kernel.Descriptor(_raw: -1), into: ptr)
            }
        }
    }

    @Test
    func `pread throws on invalid descriptor`() {
        var buffer = [UInt8](repeating: 0, count: 10)

        #expect(throws: ISO_9945.Kernel.IO.Read.Error.self) {
            try buffer.withUnsafeMutableBytes { ptr in
                try ISO_9945.Kernel.IO.Read.pread(
                    ISO_9945.Kernel.Descriptor(_raw: -1),
                    into: ptr,
                    at: ISO_9945.Kernel.File.Offset(0)
                )
            }
        }
    }
}
