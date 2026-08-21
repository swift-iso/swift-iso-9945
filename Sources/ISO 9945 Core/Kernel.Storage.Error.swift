extension ISO_9945.Kernel.Storage {

    public enum Error: Swift.Error, Sendable, Equatable, Hashable {

        case exhausted

        case quota
    }
}

extension ISO_9945.Kernel.Storage.Error: CustomStringConvertible {
    public var description: Swift.String {
        switch self {
        case .exhausted:
            return "no space left on device"

        case .quota:
            return "disk quota exceeded"
        }
    }
}
