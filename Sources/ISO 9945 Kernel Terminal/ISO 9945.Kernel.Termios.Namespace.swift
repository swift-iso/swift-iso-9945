extension ISO_9945.Kernel {

    public enum Termios: Sendable {}
}

extension ISO_9945.Kernel.Termios {

    public struct Attributes: Sendable {

        @usableFromInline
        internal var _storage: Storage

        @usableFromInline
        internal init() {
            self._storage = Storage()
        }
    }
}

extension ISO_9945.Kernel.Termios.Attributes {

    public struct Storage: Sendable {
        public var bytes:
            (
                UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64,
                UInt64, UInt64, UInt64, UInt64
            ) = (0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0)

        public init() {}
    }
}

extension ISO_9945.Kernel.Termios.Attributes {

    @_spi(Syscall)
    @inlinable
    public init(_storage: Storage) {
        self._storage = _storage
    }

    @_spi(Syscall)
    @inlinable
    public var _rawStorage: Storage {
        get { _storage }
        set { _storage = newValue }
    }

    @_spi(Syscall)
    @inlinable
    public mutating func withUnsafeMutableStorageBytes<T, E: Swift.Error>(
        _ body: (UnsafeMutableRawBufferPointer) throws(E) -> T
    ) throws(E) -> T {
        try withUnsafeMutableBytes(of: &_storage.bytes) {
            (buffer: UnsafeMutableRawBufferPointer) throws(E) -> T in
            try unsafe body(buffer)
        }
    }

    @_spi(Syscall)
    @inlinable
    public func withUnsafeStorageBytes<T, E: Swift.Error>(
        _ body: (UnsafeRawBufferPointer) throws(E) -> T
    ) throws(E) -> T {
        try withUnsafeBytes(of: _storage.bytes) {
            (buffer: UnsafeRawBufferPointer) throws(E) -> T in
            try unsafe body(buffer)
        }
    }
}

extension ISO_9945.Kernel.Termios.Attributes {

    public struct Action: Sendable, Hashable {
        @usableFromInline
        internal let _rawValue: Int32

        @_spi(Syscall)
        @inlinable
        public init(_rawValue: Int32) {
            self._rawValue = _rawValue
        }
    }
}

extension ISO_9945.Kernel.Termios.Attributes.Action {
    @_spi(Syscall)
    @inlinable
    public var rawValue: Int32 { _rawValue }
}
