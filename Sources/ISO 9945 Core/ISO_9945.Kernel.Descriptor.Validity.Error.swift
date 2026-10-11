extension ISO_9945.Kernel.Descriptor.Validity {

    public enum Error: Swift.Error, Sendable, Equatable, Hashable {

        case invalid

        case limit(Limit)
    }
}

extension ISO_9945.Kernel.Descriptor.Validity.Error: CustomStringConvertible {
    public var description: Swift.String {
        switch self {
        case .invalid:
            return "invalid descriptor"

        case .limit(let limit):
            return limit.description
        }
    }
}
