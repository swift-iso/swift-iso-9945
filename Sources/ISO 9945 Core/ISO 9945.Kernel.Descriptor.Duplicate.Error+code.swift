extension ISO_9945.Kernel.Descriptor.Duplicate.Error {

    @inlinable
    public var code: Error_Primitives.Error.Code {
        switch self {
        case .handle(let validity):
            return validity.code

        case .tooManyOpen:
            return .POSIX.EMFILE

        case .platform(let error):
            return error.code
        }
    }
}
