extension ISO_9945.Kernel.Directory {

    public struct Entry: Sendable {
        #if os(Windows)

            public let rawName: [UInt16]
        #else

            @_spi(Syscall)
            public let rawName: [UInt8]
        #endif

        public let inode: ISO_9945.Kernel.Inode?

        public let type: ISO_9945.Kernel.File.Stats.Kind?

        #if os(Windows)

            public init(
                rawName: [UInt16],
                inode: ISO_9945.Kernel.Inode? = nil,
                type: ISO_9945.Kernel.File.Stats.Kind? = nil
            ) {
                precondition(
                    rawName.last == 0,
                    "Directory.Entry rawName must be a non-empty, null-terminated sequence"
                )
                self.rawName = rawName
                self.inode = inode
                self.type = type
            }
        #else

            @_spi(Syscall)
            public init(
                rawName: [UInt8],
                inode: ISO_9945.Kernel.Inode? = nil,
                type: ISO_9945.Kernel.File.Stats.Kind? = nil
            ) {
                precondition(
                    rawName.last == 0,
                    "Directory.Entry rawName must be a non-empty, null-terminated sequence"
                )
                self.rawName = rawName
                self.inode = inode
                self.type = type
            }
        #endif

    }
}

extension ISO_9945.Kernel.Directory.Entry {

    public var isDotOrDotDot: Bool {
        #if os(Windows)
            rawName == [0x002E, 0x0000] || rawName == [0x002E, 0x002E, 0x0000]
        #else
            rawName == [0x2E, 0x00] || rawName == [0x2E, 0x2E, 0x00]
        #endif
    }

    public func withName<R, E: Swift.Error>(
        _ body: (borrowing Path.Borrowed) throws(E) -> R
    ) throws(E) -> R {
        let result: Swift.Result<R, E> = rawName.withUnsafeBufferPointer { buffer in
            let view = unsafe Path.Borrowed(buffer.baseAddress!, count: buffer.count - 1)
            do throws(E) {
                return .success(try body(view))
            } catch {
                return .failure(error)
            }
        }
        return try result.get()
    }
}
