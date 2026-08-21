extension ISO_9945.Kernel.File.Handle {

    public enum Error: Swift.Error, Sendable, Equatable {

        case invalidHandle

        case endOfFile

        case noSpace

        case misalignedBuffer(address: Memory.Address, required: Memory.Alignment)

        case misalignedOffset(offset: Int64, required: Memory.Alignment)

        case invalidLength(length: Int, requiredMultiple: Memory.Alignment)

        case requirementsUnknown

        case alignmentViolation(operation: Operation)

        case platform(code: Error_Primitives.Error.Code, operation: Operation)
    }
}

extension ISO_9945.Kernel.File.Handle.Error {

    public init(from directError: ISO_9945.Kernel.File.Direct.Error) {
        switch directError {
        case .notSupported:
            self = .requirementsUnknown

        case .misalignedBuffer(let address, let required):
            self = .misalignedBuffer(address: address, required: required)

        case .misalignedOffset(let offset, let required):
            self = .misalignedOffset(offset: offset, required: required)

        case .invalidLength(let length, let requiredMultiple):
            self = .invalidLength(length: length, requiredMultiple: requiredMultiple)

        case .modeChange:
            self = .platform(code: .posix(-1), operation: .sync)

        case .invalidHandle:
            self = .invalidHandle

        case .platform(let code, let operation):

            switch operation {
            case .open:
                self = .platform(code: code, operation: .read)

            case .cache, .sector:
                self = .platform(code: code, operation: .sync)

            case .read:
                self = .platform(code: code, operation: .read)

            case .write:
                self = .platform(code: code, operation: .write)
            }
        }
    }
}

extension ISO_9945.Kernel.File.Handle.Error: CustomStringConvertible {
    public var description: Swift.String {
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
