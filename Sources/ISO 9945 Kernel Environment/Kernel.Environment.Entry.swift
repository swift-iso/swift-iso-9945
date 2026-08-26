public import String

extension ISO_9945.Kernel.Environment {

    @safe public struct Entry: ~Copyable, ~Escapable {

        @usableFromInline
        internal let _base: UnsafePointer<String.Char>

        @usableFromInline
        internal let _separator: Int

        @usableFromInline
        internal let _length: Int

        @_spi(Syscall)
        @inlinable
        @_lifetime(borrow base)
        @unsafe
        public init(
            base: UnsafePointer<String.Char>,
            separator: Int,
            length: Int
        ) {
            unsafe (self._base = base)
            self._separator = separator
            self._length = length
        }
    }
}

extension ISO_9945.Kernel.Environment.Entry {

    @inlinable
    public var name: Swift.Span<String.Char> {
        @_lifetime(copy self) borrowing get {
            let s = unsafe Span(_unsafeStart: _base, count: _separator)
            return unsafe _overrideLifetime(s, copying: self)
        }
    }

    @inlinable
    public var value: Swift.Span<String.Char> {
        @_lifetime(copy self) borrowing get {
            let s = unsafe Span(
                _unsafeStart: _base + _separator + 1,
                count: _length - _separator - 1
            )
            return unsafe _overrideLifetime(s, copying: self)
        }
    }
}

extension ISO_9945.Kernel.Environment.Entry {

    @inlinable
    public var nameLength: Int {
        _separator
    }

    @inlinable
    public var valueLength: Int {
        _length - _separator - 1
    }
}
