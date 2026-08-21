extension ISO_9945.Kernel.File.Direct.Requirements.Alignment {

    public struct Length: Sendable {
        let alignment: ISO_9945.Kernel.File.Direct.Requirements.Alignment
    }

    public var length: Length { Length(alignment: self) }
}

extension ISO_9945.Kernel.File.Direct.Requirements.Alignment.Length {

    public func isValid(_ length: ISO_9945.Kernel.File.Size) -> Bool {
        let mask: Int64 = alignment.lengthMultiple.mask()
        return length.underlying & mask == 0
    }
}
