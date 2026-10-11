extension ISO_9945.Kernel.File.Seek {

    public struct Whence: RawRepresentable, Sendable, Hashable {
        public let rawValue: Int32

        public init(rawValue: Int32) {
            self.rawValue = rawValue
        }
    }
}
