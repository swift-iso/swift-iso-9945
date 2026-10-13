extension ISO_9945.Kernel.Descriptor.Duplicate {

    public enum Error: Swift::Error, Sendable, Equatable {

        case handle(ISO_9945.Kernel.Descriptor.Validity.Error)

        case tooManyOpen

        case platform(Error::Error)
    }
}
