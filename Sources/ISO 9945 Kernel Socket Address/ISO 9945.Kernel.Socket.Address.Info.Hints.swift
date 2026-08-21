extension ISO_9945.Kernel.Socket.Address.Info {

    public struct Hints: Sendable, Equatable, Hashable {

        public var options: ISO_9945.Kernel.Socket.Address.Info.Options

        public var family: ISO_9945.Kernel.Socket.Address.Family

        public var kind: ISO_9945.Kernel.Socket.Kind?

        public var `protocol`: Int32

        public init(
            options: ISO_9945.Kernel.Socket.Address.Info.Options = [],
            family: ISO_9945.Kernel.Socket.Address.Family = .unspecified,
            kind: ISO_9945.Kernel.Socket.Kind? = nil,
            protocol: Int32 = 0
        ) {
            self.options = options
            self.family = family
            self.kind = kind
            self.protocol = `protocol`
        }
    }
}
