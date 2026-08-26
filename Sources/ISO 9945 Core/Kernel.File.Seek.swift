extension ISO_9945.Kernel.File {

    public enum Seek: Sendable {}
}

extension ISO_9945.Kernel.File.Seek {

    public struct Whence: RawRepresentable, Sendable, Hashable {
        public let rawValue: Int32

        public init(rawValue: Int32) {
            self.rawValue = rawValue
        }
    }
}

extension ISO_9945.Kernel.File.Seek {

    public enum Error: Swift.Error, Sendable, Equatable {

        case invalidDescriptor

        case invalidSeek

        case notSeekable

        case overflow

        case platform(code: Error.Error.Code)
    }
}

extension ISO_9945.Kernel.File.Seek.Error: CustomStringConvertible {
    public var description: Swift.String {
        switch self {
        case .invalidDescriptor:
            return "Invalid file descriptor"

        case .invalidSeek:
            return
                "Invalid seek request (unrecognized whence, negative resulting offset, or offset beyond the device's maximum)"

        case .notSeekable:
            return "File descriptor is not seekable (pipe, socket, or FIFO)"

        case .overflow:
            return "Resulting offset would overflow"

        case .platform(let code):
            return "Seek failed: \(code)"
        }
    }
}
