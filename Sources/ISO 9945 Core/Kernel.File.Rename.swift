extension ISO_9945.Kernel.File {

    public enum Rename {}
}

#if os(macOS) || os(iOS) || os(tvOS) || os(watchOS) || os(visionOS) || os(Linux) || os(Android) || os(OpenBSD)
    extension ISO_9945.Kernel.File.Rename {

        public enum Error: Swift.Error, Sendable, Equatable, Hashable {

            case exists

            case notSupported

            case permission(Error_Primitives.Error.Code)

            case platform(Error_Primitives.Error.Code)
        }
    }

    extension ISO_9945.Kernel.File.Rename.Error: CustomStringConvertible {
        public var description: Swift.String {
            switch self {
            case .exists:
                return "rename failed: destination exists"

            case .notSupported:
                return "rename operation not supported"

            case .permission(let code):
                return "rename permission denied (\(code))"

            case .platform(let code):
                return "rename failed (\(code))"
            }
        }
    }

#endif
