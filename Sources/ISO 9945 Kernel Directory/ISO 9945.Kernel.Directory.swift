@_spi(Syscall) import ISO_9945_Core

#if canImport(Darwin)
    internal import Darwin
#elseif canImport(Glibc)
    internal import Glibc
#elseif canImport(Musl)
    internal import Musl
#endif

extension ISO_9945.Kernel.Directory {
    public typealias Entry = ISO_9945.Kernel.Directory.Entry
    public typealias Error = ISO_9945.Kernel.Directory.Error

    @safe
    public final class Stream {
        #if canImport(Darwin)
            private var dir: UnsafeMutablePointer<DIR>?

            fileprivate init(dir: UnsafeMutablePointer<DIR>) {
                unsafe self.dir = dir
            }
        #else
            private var dir: OpaquePointer?

            fileprivate init(dir: OpaquePointer) {
                unsafe self.dir = dir
            }
        #endif

        deinit {
            if let d = unsafe dir {
                unsafe closedir(d)
            }
        }
    }

    @unsafe
    public static func open(at path: UnsafePointer<Path.Char>) throws(Error) -> Stream {
        let cPath = unsafe UnsafePointer<CChar>(path)

        guard let dir = unsafe opendir(cPath) else {
            throw Error.currentOpen()
        }
        return unsafe Stream(dir: dir)
    }

    public static func open(at path: borrowing Path.Borrowed) throws(Error) -> Stream {
        try unsafe path.withUnsafePointer { (ptr: UnsafePointer<Path.Char>) throws(Error) in
            try unsafe open(at: ptr)
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

extension ISO_9945.Kernel.Directory.Error {

    internal static func currentOpen() -> Self {
        let code = Error_Primitives.Error.Code.current()
        switch code {
        case .ENOENT:
            return .notFound

        case .EACCES:
            return .permission

        case .ENOTDIR:
            return .notDirectory

        case .EMFILE, .ENFILE:
            return .tooManyOpenFiles

        default:
            return .platform(Error_Primitives.Error(code: code))
        }
    }

    internal static func currentRead() -> Self {
        let code = Error_Primitives.Error.Code.current()
        switch code {
        case .EIO:
            return .io

        default:
            return .platform(Error_Primitives.Error(code: code))
        }
    }
}
