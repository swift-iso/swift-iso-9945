extension ISO_9945.Kernel.Resource.Limit {

    public enum Error: Swift::Error, Sendable, Equatable {

        /// `EINVAL`: the resource is unknown, or `current` exceeds `maximum`.
        case invalid

        /// `EPERM`: raising `maximum` needs privilege.
        case permission

        case platform(Error::Error)
    }
}

extension ISO_9945.Kernel.Resource.Limit.Error {

    internal init(code: Error::Error.Code) {
        switch code {
        case .EINVAL: self = .invalid
        case .EPERM: self = .permission
        default: self = .platform(Error::Error(code: code))
        }
    }
}

extension ISO_9945.Kernel.Resource.Limit.Error: CustomStringConvertible {
    public var description: Swift::String {
        switch self {
        case .invalid: return "invalid resource limit"
        case .permission: return "permission denied"
        case .platform(let e): return "\(e)"
        }
    }
}
