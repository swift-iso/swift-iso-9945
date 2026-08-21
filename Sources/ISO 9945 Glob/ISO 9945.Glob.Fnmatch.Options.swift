internal import ISO_9945_Shims

extension ISO_9945.Glob.Fnmatch {

    public struct Options: OptionSet, Sendable {
        public let rawValue: Int32

        @inlinable
        public init(rawValue: Int32) {
            self.rawValue = rawValue
        }
    }
}

extension ISO_9945.Glob.Fnmatch.Options {

    public static let pathname = Self(rawValue: iso9945_fnm_pathname())

    public static let noescape = Self(rawValue: iso9945_fnm_noescape())

    public static let period = Self(rawValue: iso9945_fnm_period())

    public static let casefold = Self(rawValue: iso9945_fnm_casefold())
}
