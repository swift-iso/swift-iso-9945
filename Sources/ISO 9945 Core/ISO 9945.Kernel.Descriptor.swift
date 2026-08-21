#if canImport(Darwin)
    internal import Darwin
#elseif canImport(Glibc)
    internal import Glibc
#elseif canImport(Musl)
    internal import Musl
#endif

extension ISO_9945.Kernel {

    public struct Descriptor: ~Copyable, Sendable {
        @usableFromInline
        package var _raw: Int32

        @usableFromInline
        package init(_raw: Int32) {
            self._raw = _raw
        }

        deinit {
            guard isValid else { return }
            #if canImport(Darwin)
                _ = Darwin.close(_raw)
            #elseif canImport(Glibc)
                _ = unsafe Glibc.close(_raw)
            #elseif canImport(Musl)
                _ = unsafe Musl.close(_raw)
            #endif
        }
    }
}

extension ISO_9945.Kernel.Descriptor {

    public static var invalid: Self {
        Self(_raw: -1)
    }

    @inlinable
    public var isValid: Bool {
        _raw >= 0
    }
}

extension ISO_9945.Kernel.Descriptor {

    @_spi(Syscall)
    @inlinable
    public init(_rawValue: Int32) {
        self._raw = _rawValue
    }

    @_spi(Syscall)
    @inlinable
    public var _rawValue: Int32 { _raw }
}
