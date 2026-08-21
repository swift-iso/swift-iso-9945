extension ISO_9945.Kernel {

    public enum TTY: Sendable {}
}

extension ISO_9945.Kernel.TTY {

    public struct Size: Sendable, Hashable {

        public let rows: UInt16

        public let columns: UInt16

        @inlinable
        public init(rows: UInt16, columns: UInt16) {
            self.rows = rows
            self.columns = columns
        }
    }
}
