extension ISO_9945.Kernel.File.Copy {

    public struct Options: Sendable, Equatable {

        public var overwrite: Bool

        public var copyAttributes: Bool

        public var followSymlinks: Bool

        public init(
            overwrite: Bool = false,
            copyAttributes: Bool = true,
            followSymlinks: Bool = true
        ) {
            self.overwrite = overwrite
            self.copyAttributes = copyAttributes
            self.followSymlinks = followSymlinks
        }
    }
}
