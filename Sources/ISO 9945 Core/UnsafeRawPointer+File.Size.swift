extension UnsafeMutableRawPointer {

    @inlinable
    @unsafe
    public func advanced(by size: ISO_9945.Kernel.File.Size) -> UnsafeMutableRawPointer {
        unsafe advanced(by: Int(size))
    }
}

extension UnsafeRawPointer {

    @inlinable
    @unsafe
    public func advanced(by size: ISO_9945.Kernel.File.Size) -> UnsafeRawPointer {
        unsafe advanced(by: Int(size))
    }
}
