extension ISO_9945.Kernel.File {

    public enum Attributes {}
}

extension ISO_9945.Kernel.File.Attributes {

    public enum Error: Swift.Error, Sendable, Equatable {

        case path(Path)

        case permission(Permission)

        case io(IO)

        case platform(Error.Error)
    }
}

extension ISO_9945.Kernel.File.Attributes.Error {

    public enum Path: Swift.Error, Sendable, Equatable {
        case notFound
        case tooLong
        case loop
    }

    public enum Permission: Swift.Error, Sendable, Equatable {
        case denied
        case notPermitted
        case readOnlyFilesystem
    }

    public enum IO: Swift.Error, Sendable, Equatable {
        case hardware
    }
}

extension ISO_9945.Kernel.File.Attributes.Error: CustomStringConvertible {
    public var description: Swift.String {
        switch self {
        case .path(let pathError):
            return "file attributes path error: \(pathError)"

        case .permission(let permError):
            return "file attributes permission error: \(permError)"

        case .io(let ioError):
            return "file attributes I/O error: \(ioError)"

        case .platform(let e):
            return "file attributes error: \(e)"
        }
    }
}
