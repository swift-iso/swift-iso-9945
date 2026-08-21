extension ISO_9945.Kernel.Lock {

    public enum Range: Sendable, Equatable, Hashable {

        case file

        case bytes(start: ISO_9945.Kernel.File.Offset, end: ISO_9945.Kernel.File.Offset)

        @inlinable
        public init(
            forMappingAt offset: ISO_9945.Kernel.File.Offset,
            length: ISO_9945.Kernel.File.Size,
            granularity: Memory.Allocation.Granularity
        ) {

            let (sum, overflow) = offset.underlying.addingReportingOverflow(length.underlying)
            guard !overflow else {
                self = .bytes(start: offset, end: .max)
                return
            }
            let roundedEnd = granularity.underlying.alignUp(ISO_9945.Kernel.File.Offset(sum))
            self = .bytes(start: offset, end: roundedEnd)
        }
    }
}

extension ISO_9945.Kernel.Lock.Range {

    @inlinable
    public static func bytes(
        start: ISO_9945.Kernel.File.Offset,
        length: ISO_9945.Kernel.File.Size
    ) -> Self {

        let (sum, overflow) = start.underlying.addingReportingOverflow(length.underlying)
        return .bytes(start: start, end: overflow ? .max : ISO_9945.Kernel.File.Offset(sum))
    }
}
