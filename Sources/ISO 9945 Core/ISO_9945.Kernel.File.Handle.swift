extension ISO_9945.Kernel.File {

    @frozen
    public struct Handle: ~Copyable, Sendable {

        public let descriptor: ISO_9945.Kernel.File.Descriptor

        public let direct: ISO_9945.Kernel.File.Direct.Mode.Resolved

        public let requirements: ISO_9945.Kernel.File.Direct.Requirements

        public init(
            descriptor: consuming ISO_9945.Kernel.File.Descriptor,
            direct: ISO_9945.Kernel.File.Direct.Mode.Resolved,
            requirements: ISO_9945.Kernel.File.Direct.Requirements
        ) {
            self.descriptor = descriptor
            self.direct = direct
            self.requirements = requirements
        }

    }
}

extension ISO_9945.Kernel.File.Handle {

    private func validateAlignment(
        buffer: Memory.Address,
        offset: ISO_9945.Kernel.File.Offset,
        length: ISO_9945.Kernel.File.Size
    ) throws(ISO_9945.Kernel.File.Handle.Error) {
        guard case .known(let alignment) = requirements else {
            throw .requirementsUnknown
        }

        if let directError = alignment.validate(buffer: buffer, offset: offset, length: length) {
            throw Error(from: directError)
        }
    }
}
