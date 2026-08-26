#if !os(Windows)

    import Path
    import Error
    public import ISO_9945_Kernel
    @_spi(Syscall) import ISO_9945_Kernel_File

    public enum KernelIOTest {

        public static func makeTempPath(prefix: Swift.String = "io-test") -> Swift.String {
            ISO_9945.Kernel.Temporary.filePath(prefix: prefix)
        }

        public static func open(at path: Swift.String) throws -> ISO_9945.Kernel.Descriptor {
            try Path.scope(path) { p in
                try ISO_9945.Kernel.File.Open.open(
                    path: p,
                    mode: .readWrite,
                    options: [.create, .truncate, .exclusive],
                    permissions: .ownerReadWrite
                )
            }
        }

        public static func write(
            _ content: Swift.String,
            to fd: borrowing ISO_9945.Kernel.Descriptor
        ) {
            var bytes = Array(content.utf8)
            _ = try? bytes.withUnsafeMutableBytes { ptr in
                try unsafe ISO_9945.Kernel.IO.Write.write(fd, from: UnsafeRawBufferPointer(ptr))
            }
        }

        public static func cleanup(path: Swift.String) {
            try? Path.scope(path) { p in
                try ISO_9945.Kernel.File.Delete.delete(p)
            }
        }
    }

#endif
