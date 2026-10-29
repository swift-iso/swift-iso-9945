extension ISO_9945.Kernel.File.Move {

    public enum Error: Swift::Error, Sendable, Equatable {

        case notFound

        case permission

        case crossDevice

        case exists

        case notSupported

        case notEmpty

        case notDirectory

        case invalidArgument

        case isDirectory

        case readOnly

        case loop

        case nameTooLong

        case noSpace

        case platform(Error::Error)
    }
}

extension ISO_9945.Kernel.File.Move.Error: CustomStringConvertible {
    public var description: Swift::String {
        switch self {
        case .notFound: return "source path not found"
        case .permission: return "permission denied"
        case .crossDevice: return "cross-device move not supported"
        case .exists: return "destination exists"
        case .notSupported: return "operation not supported by this file system"
        case .notEmpty: return "destination directory not empty"
        case .notDirectory: return "path component is not a directory"
        case .invalidArgument: return "invalid argument"
        case .isDirectory: return "cannot overwrite directory with file"
        case .readOnly: return "read-only filesystem"
        case .loop: return "too many symbolic links"
        case .nameTooLong: return "path name too long"
        case .noSpace: return "no space left on device"
        case .platform(let e): return "\(e)"
        }
    }
}
