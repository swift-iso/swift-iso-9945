extension ISO_9945.Kernel.File.Direct.Requirements.Alignment {

    public struct Buffer: Sendable {
        let alignment: ISO_9945.Kernel.File.Direct.Requirements.Alignment
    }

    public var buffer: Buffer { Buffer(alignment: self) }
}

extension ISO_9945.Kernel.File.Direct.Requirements.Alignment.Buffer {

    public func isAligned(_ address: Memory.Address) -> Bool {
        alignment.bufferAlignment.isAligned(address.bitPattern)
    }
}
