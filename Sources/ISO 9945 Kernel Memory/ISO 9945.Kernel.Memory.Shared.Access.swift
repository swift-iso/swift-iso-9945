extension Memory.Shared {

    public struct Access: Sendable, Hashable {

        public let read: Bool

        public let write: Bool

        @inlinable
        public init(read: Bool, write: Bool) {
            self.read = read
            self.write = write
        }
    }
}

extension Memory.Shared.Access {

    public static let read = Self(read: true, write: false)

    public static let write = Self(read: false, write: true)

    public static let readWrite = Self(read: true, write: true)
}
