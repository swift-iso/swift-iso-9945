extension ISO_9945.Kernel.Descriptor.Validity.Error {

    public enum Limit: Sendable, Equatable, Hashable {

        case process

        case system
    }
}

extension ISO_9945.Kernel.Descriptor.Validity.Error.Limit: CustomStringConvertible {
    public var description: Swift.String {
        switch self {
        case .process:
            return "too many open files in process"

        case .system:
            return "too many open files in system"
        }
    }
}
