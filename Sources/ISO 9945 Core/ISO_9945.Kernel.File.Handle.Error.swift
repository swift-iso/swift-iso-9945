extension ISO_9945.Kernel.File.Handle {

    public enum Error: Swift::Error, Sendable, Equatable {

        case invalidHandle

        case endOfFile

        case noSpace

        case misalignedBuffer(address: Memory.Address, required: Memory.Alignment)

        case misalignedOffset(offset: Int64, required: Memory.Alignment)

        case invalidLength(length: Int, requiredMultiple: Memory.Alignment)

        case requirementsUnknown

        case alignmentViolation(operation: Operation)

        case platform(code: Error::Error.Code, operation: Operation)
    }
}

extension ISO_9945.Kernel.File.Handle.Error: CustomStringConvertible {
    public var description: Swift::String {
        switch self {
        case .invalidHandle:
            return "Invalid file handle"

        case .endOfFile:
            return "End of file"

        case .noSpace:
            return "No space left on device"

        case .misalignedBuffer(let address, let required):
            return "Buffer address \(address) not aligned to \(required)"

        case .misalignedOffset(let offset, let required):
            return "File offset \(offset) not aligned to \(required) bytes"

        case .invalidLength(let length, let requiredMultiple):
            return "Length \(length) is not a multiple of \(requiredMultiple)"

        case .requirementsUnknown:
            return "Direct I/O requirements unknown"

        case .alignmentViolation(let operation):
            return "Alignment violation or Direct I/O not supported during \(operation.rawValue)"

        case .platform(let code, let operation):
            return "Platform error \(code) during \(operation.rawValue)"
        }
    }
}
