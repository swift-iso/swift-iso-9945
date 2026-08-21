extension ISO_9945.Kernel.File.Direct.Requirements {

    public struct Alignment: Sendable, Equatable {

        public let bufferAlignment: Memory.Alignment

        public let offsetAlignment: Memory.Alignment

        public let lengthMultiple: Memory.Alignment

        public init(
            bufferAlignment: Memory.Alignment,
            offsetAlignment: Memory.Alignment,
            lengthMultiple: Memory.Alignment
        ) {
            self.bufferAlignment = bufferAlignment
            self.offsetAlignment = offsetAlignment
            self.lengthMultiple = lengthMultiple
        }

        public init(uniform alignment: Memory.Alignment) {
            self.bufferAlignment = alignment
            self.offsetAlignment = alignment
            self.lengthMultiple = alignment
        }
    }
}

extension ISO_9945.Kernel.File.Direct.Requirements.Alignment {

    public func validate(
        buffer bufferAddress: Memory.Address,
        offset fileOffset: ISO_9945.Kernel.File.Offset,
        length transferLength: ISO_9945.Kernel.File.Size
    ) -> ISO_9945.Kernel.File.Direct.Error? {
        if !buffer.isAligned(bufferAddress) {
            return .misalignedBuffer(
                address: bufferAddress,
                required: bufferAlignment
            )
        }
        if !offset.isAligned(fileOffset) {
            return .misalignedOffset(
                offset: fileOffset.underlying,
                required: offsetAlignment
            )
        }
        if !length.isValid(transferLength) {
            return .invalidLength(
                length: Int(transferLength),
                requiredMultiple: lengthMultiple
            )
        }
        return nil
    }
}
