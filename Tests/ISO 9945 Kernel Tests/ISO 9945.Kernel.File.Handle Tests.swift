import Error_Primitives
import ISO_9945_Kernel_Test_Support
import Path_Primitives
import Tagged_Primitives_Standard_Library_Integration
import Testing

@testable import ISO_9945_Kernel

extension ISO_9945.Kernel.File.Handle {
    @Suite
    struct Test {
        @Suite struct Unit {}
        @Suite struct `Edge Case` {}
        @Suite struct Integration {}
        @Suite(.serialized) struct Performance {}
    }
}

private func cleanup(path: Swift.String) {
    try? Path.scope(path) { p in
        try ISO_9945.Kernel.File.Delete.delete(p)
    }
}

extension ISO_9945.Kernel.File.Handle.Test.Unit {
    @Test
    func `init stores descriptor and mode`() throws {
        let path = KernelIOTest.makeTempPath(prefix: "handle-test")
        let fd = try KernelIOTest.open(at: path)

        defer { cleanup(path: path) }

        let handle = ISO_9945.Kernel.File.Handle(
            descriptor: fd,
            direct: .buffered,
            requirements: .unknown(reason: .platformUnsupported)
        )

        #expect(handle.direct == .buffered)

        _ = consume handle
    }

    @Test
    func `read returns bytes from file`() throws {
        let path = KernelIOTest.makeTempPath(prefix: "handle-test")
        let fd = try KernelIOTest.open(at: path)
        defer { cleanup(path: path) }
        KernelIOTest.write("Hello, Handle!", to: fd)

        _ = try ISO_9945.Kernel.File.Seek.seek(fd, offset: 0, whence: .start)

        let handle = ISO_9945.Kernel.File.Handle(
            descriptor: fd,
            direct: .buffered,
            requirements: .unknown(reason: .platformUnsupported)
        )

        var buffer = [UInt8](repeating: 0, count: 14)
        let bytesRead = try buffer.withUnsafeMutableBytes { ptr in
            try handle.read(into: ptr)
        }

        #expect(bytesRead == 14)
        #expect(Swift.String(decoding: buffer, as: UTF8.self) == "Hello, Handle!")
    }

    @Test
    func `write writes bytes to file`() throws {
        let path = KernelIOTest.makeTempPath(prefix: "handle-test")
        let fd = try KernelIOTest.open(at: path)
        defer { cleanup(path: path) }

        let handle = ISO_9945.Kernel.File.Handle(
            descriptor: fd,
            direct: .buffered,
            requirements: .unknown(reason: .platformUnsupported)
        )

        let content = Array("Handle write!".utf8)
        let bytesWritten = try content.withUnsafeBytes { ptr in
            try handle.write(from: ptr)
        }

        #expect(bytesWritten == 13)

        _ = try ISO_9945.Kernel.File.Seek.seek(handle.descriptor, offset: 0, whence: .start)
        var buffer = [UInt8](repeating: 0, count: 13)
        let bytesRead = try buffer.withUnsafeMutableBytes { ptr in
            try handle.read(into: ptr)
        }
        #expect(Swift.String(decoding: buffer, as: UTF8.self) == "Handle write!")
    }

    @Test
    func `close explicitly closes handle`() throws {
        let path = KernelIOTest.makeTempPath(prefix: "handle-test")
        let fd = try KernelIOTest.open(at: path)
        defer { cleanup(path: path) }

        let handle = ISO_9945.Kernel.File.Handle(
            descriptor: fd,
            direct: .buffered,
            requirements: .unknown(reason: .platformUnsupported)
        )

        try handle.close()

        let fd2 = try Path.scope(path) { p in
            try ISO_9945.Kernel.File.Open.open(
                path: p,
                mode: .read,
                options: [],
                permissions: .ownerReadWrite
            )
        }
        let fd2IsValid = fd2.isValid
        #expect(fd2IsValid)
    }

    @Test
    func `descriptor property provides borrowing access`() throws {
        let path = KernelIOTest.makeTempPath(prefix: "handle-test")
        let fd = try KernelIOTest.open(at: path)
        defer { cleanup(path: path) }

        let handle = ISO_9945.Kernel.File.Handle(
            descriptor: fd,
            direct: .buffered,
            requirements: .unknown(reason: .platformUnsupported)
        )

        let isValid = handle.descriptor.isValid
        #expect(isValid)

        _ = consume handle
    }

    @Test
    func `handle closes on deinit`() throws {
        let path = KernelIOTest.makeTempPath(prefix: "handle-test")
        let fd = try KernelIOTest.open(at: path)
        defer { cleanup(path: path) }

        do {
            let handle = ISO_9945.Kernel.File.Handle(
                descriptor: fd,
                direct: .buffered,
                requirements: .unknown(reason: .platformUnsupported)
            )
            _ = consume handle
        }

        let fd2 = try Path.scope(path) { p in
            try ISO_9945.Kernel.File.Open.open(
                path: p,
                mode: .read,
                options: [],
                permissions: .ownerReadWrite
            )
        }
        let fd2IsValid = fd2.isValid
        #expect(fd2IsValid)
    }
}

extension ISO_9945.Kernel.File.Handle.Test.Unit {
    @Test
    func `direct mode enum is equatable`() {
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
