#if canImport(Darwin)
    internal import Darwin
#elseif canImport(Glibc)
    internal import Glibc
#elseif canImport(Musl)
    internal import Musl
#endif

extension ISO_9945.Kernel.IO.Vector {

    @unsafe
    public struct Segment: @unchecked Sendable {

        public var base: UnsafeMutableRawPointer?

        public var length: Int

        @unsafe
        public init(base: UnsafeMutableRawPointer?, length: Int) {
            unsafe self.base = unsafe base
            unsafe self.length = length
        }
    }
}

extension ISO_9945.Kernel.IO.Vector.Segment {

    @unsafe
    public init(_ buffer: UnsafeMutableRawBufferPointer) {
        unsafe self.base = buffer.baseAddress
        unsafe self.length = buffer.count
    }

    @unsafe
    public init(_ buffer: UnsafeRawBufferPointer) {
        unsafe self.base = unsafe UnsafeMutableRawPointer(mutating: buffer.baseAddress)
        unsafe self.length = buffer.count
    }
}

extension ISO_9945.Kernel.IO.Vector.Segment {

    var cValue: iovec {
        unsafe iovec(iov_base: unsafe base, iov_len: length)
    }

    @unsafe
    init(_ cValue: iovec) {
        unsafe self.base = unsafe cValue.iov_base
        unsafe self.length = unsafe cValue.iov_len
    }
}
