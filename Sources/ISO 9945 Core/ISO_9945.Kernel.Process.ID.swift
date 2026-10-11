extension ISO_9945.Kernel.Process {

    public struct ID: RawRepresentable, Sendable, Hashable {
        public let rawValue: Int32

        public init(rawValue: Int32) {
            self.rawValue = rawValue
        }

        public init(_ rawValue: Int32) {
            self.rawValue = rawValue
        }
    }
}

extension ISO_9945.Kernel.Process.ID {

    public static var `init`: Self { Self(1) }
}
