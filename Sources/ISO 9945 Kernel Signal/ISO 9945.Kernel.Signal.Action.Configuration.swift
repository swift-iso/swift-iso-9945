extension ISO_9945.Kernel.Signal.Action {

    @safe
    public struct Configuration: Sendable {

        public let handler: Handler

        public let mask: ISO_9945.Kernel.Signal.Set

        public let flags: Options

        @unsafe
        public init(
            handler: Handler,
            mask: ISO_9945.Kernel.Signal.Set = ISO_9945.Kernel.Signal.Set(),
            flags: Options = []
        ) {
            unsafe (self.handler = handler)
            self.mask = mask

            switch unsafe handler {
            case .customInfo:

                self.flags = flags.union(.sigInfo)

            case .custom:

                self.flags = flags.subtracting(.sigInfo)

            case .default, .ignore:
                self.flags = flags
            }
        }

        @unsafe
        internal init(
            __unchecked: Void,
            handler: Handler,
            mask: ISO_9945.Kernel.Signal.Set,
            flags: Options
        ) {
            unsafe (self.handler = handler)
            self.mask = mask
            self.flags = flags
        }
    }
}
