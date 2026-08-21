extension ISO_9945.Kernel.File.Open {

    public struct Mode: Sendable, Hashable {

        public let read: Bool

        public let write: Bool

        @inlinable
        public init(read: Bool, write: Bool) {
            self.read = read
            self.write = write
        }
    }
}

extension ISO_9945.Kernel.File.Open.Mode {

    public static let read = Self(read: true, write: false)

    public static let write = Self(read: false, write: true)

    public static let readWrite = Self(read: true, write: true)
}
