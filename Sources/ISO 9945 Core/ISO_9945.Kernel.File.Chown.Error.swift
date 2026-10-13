extension ISO_9945.Kernel.File.Chown {

    public enum Error: Swift::Error, Sendable, Equatable {

        case path(Path)

        case permission(Permission)

        case io(IO)

        case platform(Error::Error)
    }
}

extension ISO_9945.Kernel.File.Chown.Error: CustomStringConvertible {
    public var description: Swift::String {
        switch self {
        case .path(let pathError):
            return "chown path error: \(pathError)"

        case .permission(let permError):
            return "chown permission error: \(permError)"

        case .io(let ioError):
            return "chown I/O error: \(ioError)"

        case .platform(let e):
            return "chown error: \(e)"
        }
    }
}
