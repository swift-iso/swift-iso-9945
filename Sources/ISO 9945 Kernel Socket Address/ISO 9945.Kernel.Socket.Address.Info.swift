extension ISO_9945.Kernel.Socket.Address {

    public struct Info: Sendable, Equatable {

        public let family: ISO_9945.Kernel.Socket.Address.Family

        public let kind: ISO_9945.Kernel.Socket.Kind

        public let `protocol`: Int32

        public let address: ISO_9945.Kernel.Socket.Address.Storage

        public let length: ISO_9945.Kernel.Socket.Address.Length

        public let canonical: String?

        public init(
            family: ISO_9945.Kernel.Socket.Address.Family,
            kind: ISO_9945.Kernel.Socket.Kind,
            protocol: Int32,
            address: ISO_9945.Kernel.Socket.Address.Storage,
            length: ISO_9945.Kernel.Socket.Address.Length,
            canonical: String? = nil
        ) {
            self.family = family
            self.kind = kind
            self.protocol = `protocol`
            self.address = address
            self.length = length
            self.canonical = canonical
        }
    }
}

extension ISO_9945.Kernel.Socket.Address.Info {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        guard
            lhs.family == rhs.family,
            lhs.kind == rhs.kind,
            lhs.protocol == rhs.protocol,
            lhs.length == rhs.length,
            lhs.canonical == rhs.canonical
        else { return false }
        return unsafe lhs.address.withUnsafeBytes { left, leftCapacity in
            unsafe rhs.address.withUnsafeBytes { right, rightCapacity in
                let count = Int(min(leftCapacity, rightCapacity))
                let length = Int(lhs.length.underlying.rawValue)
                guard length <= count else { return false }
                return unsafe UnsafeRawBufferPointer(start: left, count: length)
                    .elementsEqual(unsafe UnsafeRawBufferPointer(start: right, count: length))
            }
        }
    }
}
