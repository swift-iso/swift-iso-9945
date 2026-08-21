extension ISO_9945.Kernel.Process.Spawn.Actions {

    public struct Target: Sendable, Equatable, Hashable {
        @usableFromInline
        internal let _raw: Int32

        @inlinable
        package init(_raw: Int32) {
            self._raw = _raw
        }

        public init(_ descriptor: borrowing ISO_9945.Kernel.Descriptor) {
            self._raw = descriptor._raw
        }
    }
}

extension ISO_9945.Kernel.Process.Spawn.Actions.Target {

    public static let stdin = Self(_raw: 0)

    public static let stdout = Self(_raw: 1)

    public static let stderr = Self(_raw: 2)
}
