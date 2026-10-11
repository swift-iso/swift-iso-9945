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
