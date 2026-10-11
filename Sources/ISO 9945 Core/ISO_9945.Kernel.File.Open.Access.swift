extension ISO_9945.Kernel.File.Open {

    public enum Access: Sendable, Hashable {

        case readOnly

        case writeOnly

        case readWrite
    }
}

extension ISO_9945.Kernel.File.Open.Access {

    @inlinable
    public var rawValue: Int32 {
        switch self {
        case .readOnly: 0
        case .writeOnly: 1
        case .readWrite: 2
        }
    }
}
