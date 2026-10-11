extension Memory.Allocation.Error {

    @inlinable
    public init?(code: Error::Error.Code) {
        switch code {
        case .ENOMEM:
            self = .exhausted

        default:
            return nil
        }
    }
}
