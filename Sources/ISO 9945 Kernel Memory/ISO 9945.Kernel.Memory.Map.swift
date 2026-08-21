@_spi(Syscall) import ISO_9945_Core
import Memory_Primitives

#if canImport(Darwin)
    internal import Darwin
#elseif canImport(Glibc)
    internal import Glibc
#elseif canImport(Musl)
    internal import Musl
#endif

extension Memory.Map {

    internal static func map(
        addr: Memory.Address? = nil,
        length: Memory.Address.Count,
        protection: Protection,
        flags: Options,
        fd: Int32 = -1,
        offset: ISO_9945.Kernel.File.Offset = .zero
    ) throws(Error) -> Memory.Address {
        guard length.underlying.rawValue > 0,
            let byteCount = Int(exactly: length.underlying.rawValue)
        else {
            throw .invalid(.length)
        }

        let result = unsafe mmap(
            addr?.mutablePointer,
            byteCount,
            protection.rawValue,
            flags.rawValue,
            fd,
            off_t(offset.underlying)
        )

        guard unsafe result != MAP_FAILED else {
            throw .map(.captureErrno())
        }

        return unsafe Memory.Address(result!)
    }

    public static func map(
        addr: Memory.Address? = nil,
        length: Memory.Address.Count,
        protection: Protection,
        flags: Options,
        descriptor: borrowing ISO_9945.Kernel.Descriptor,
        offset: ISO_9945.Kernel.File.Offset = .zero
    ) throws(Error) -> Memory.Address {
        try map(
            addr: addr,
            length: length,
            protection: protection,
            flags: flags,
            fd: descriptor._rawValue,
            offset: offset
        )
    }

    public static func unmap(
        addr: Memory.Address,
        length: Memory.Address.Count
    ) throws(Error) {
        guard length.underlying.rawValue > 0,
            let byteCount = Int(exactly: length.underlying.rawValue)
        else {
            throw .invalid(.length)
        }
        guard unsafe munmap(addr.mutablePointer, byteCount) == 0 else {
            throw .unmap(.captureErrno())
        }
    }

    public static func unmap(_ region: Region) throws(Error) {
        try unmap(addr: region.base, length: region.length)
    }

    public static func sync(
        addr: Memory.Address,
        length: Memory.Address.Count,
        flags: Sync.Options = .sync
    ) throws(Error) {
        guard length.underlying.rawValue > 0,
            let byteCount = Int(exactly: length.underlying.rawValue)
        else {
            throw .invalid(.length)
        }
        guard unsafe msync(addr.mutablePointer, byteCount, flags.rawValue) == 0 else {
            throw .sync(.captureErrno())
        }
    }

    public static func protect(
        addr: Memory.Address,
        length: Memory.Address.Count,
        protection: Protection
    ) throws(Error) {
        guard length.underlying.rawValue > 0,
            let byteCount = Int(exactly: length.underlying.rawValue)
        else {
            throw .invalid(.length)
        }
        guard unsafe mprotect(addr.mutablePointer, byteCount, protection.rawValue) == 0 else {
            throw .protect(.captureErrno())
        }
    }

    public static func advise(
        addr: Memory.Address,
        length: Memory.Address.Count,
        advice: Advice
    ) {

        guard let byteCount = Int(exactly: length.underlying.rawValue) else {
            return
        }
        unsafe _ = madvise(addr.mutablePointer, byteCount, advice.rawValue)
    }
}
