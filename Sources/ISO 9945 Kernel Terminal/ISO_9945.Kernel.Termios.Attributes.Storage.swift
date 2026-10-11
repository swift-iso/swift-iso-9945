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
