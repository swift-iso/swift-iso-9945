extension ISO_9945.Kernel.File {

    @frozen
    public struct Handle: ~Copyable, Sendable {

        public let descriptor: ISO_9945.Kernel.Descriptor

        public init(descriptor: consuming ISO_9945.Kernel.Descriptor) {
            self.descriptor = descriptor
        }
    }
}
