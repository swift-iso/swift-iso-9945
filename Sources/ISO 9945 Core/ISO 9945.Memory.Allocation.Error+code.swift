extension Memory.Allocation.Error {

    @inlinable
    public init?(code: Error_Primitives.Error.Code) {
        switch code {
        case .POSIX.ENOMEM:
            self = .exhausted

        default:
            return nil
        }
    }
}
