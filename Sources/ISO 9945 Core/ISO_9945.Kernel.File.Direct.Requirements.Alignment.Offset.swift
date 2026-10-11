extension ISO_9945.Kernel.File.Direct.Requirements.Alignment {

    public struct Offset: Sendable {
        let alignment: ISO_9945.Kernel.File.Direct.Requirements.Alignment
    }

    public var offset: Offset { Offset(alignment: self) }
}

extension ISO_9945.Kernel.File.Direct.Requirements.Alignment.Offset {

    public func isAligned(_ offset: ISO_9945.Kernel.File.Offset) -> Bool {
        let mask: Int64 = alignment.offsetAlignment.mask()
        return offset.underlying & mask == 0
    }
}
