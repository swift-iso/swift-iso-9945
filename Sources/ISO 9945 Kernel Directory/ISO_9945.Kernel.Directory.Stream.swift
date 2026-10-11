@_spi(Syscall) import ISO_9945_Core

#if canImport(Darwin)
    internal import Darwin
#elseif canImport(Glibc)
    internal import Glibc
#elseif canImport(Musl)
    internal import Musl
#endif

extension ISO_9945.Kernel.Directory {

    @safe
    public final class Stream {
        #if canImport(Darwin)
            private var dir: UnsafeMutablePointer<DIR>?

            init(dir: UnsafeMutablePointer<DIR>) {
                unsafe self.dir = dir
            }
        #else
            private var dir: OpaquePointer?

            init(dir: OpaquePointer) {
                unsafe self.dir = dir
            }
        #endif

        deinit {
            if let d = unsafe dir {
                unsafe closedir(d)
            }
        }
    }
}

extension ISO_9945.Kernel.Directory.Stream {

    public func close() {
        if let d = unsafe dir {
            unsafe closedir(d)
            unsafe self.dir = nil
        }
    }

    public func next() throws(ISO_9945.Kernel.Directory.Error) -> ISO_9945.Kernel.Directory.Entry? {
        guard let d = unsafe dir else {
            throw ISO_9945.Kernel.Directory.Error.closed
        }

        errno = 0
        guard let entry = unsafe readdir(d) else {

            if errno != 0 {
                throw ISO_9945.Kernel.Directory.Error.currentRead()
            }
            return nil
        }

        let rawName: [UInt8] = unsafe withUnsafePointer(to: entry.pointee.d_name) { ptr in
            let bufferSize = MemoryLayout.size(ofValue: unsafe entry.pointee.d_name)
            return unsafe ptr.withMemoryRebound(to: UInt8.self, capacity: bufferSize) { bytes in
                var length = 0
                while length < bufferSize && (unsafe bytes[length]) != 0 {
                    length += 1
                }
                var name = unsafe Array(UnsafeBufferPointer(start: bytes, count: length))
                name.append(0)
                return name
            }
        }

        let type: ISO_9945.Kernel.File.Stats.Kind? = {
            switch Int(unsafe entry.pointee.d_type) {
            case Int(DT_REG): return .regular
            case Int(DT_DIR): return .directory
            case Int(DT_LNK): return .link(.symbolic)
            case Int(DT_CHR): return .device(.character)
            case Int(DT_BLK): return .device(.block)
            case Int(DT_FIFO): return .fifo
            case Int(DT_SOCK): return .socket
            default: return nil
            }
        }()

        return ISO_9945.Kernel.Directory.Entry(
            rawName: rawName,
            inode: ISO_9945.Kernel.Inode(UInt64(unsafe entry.pointee.d_ino)),
            type: type
        )
    }
}
