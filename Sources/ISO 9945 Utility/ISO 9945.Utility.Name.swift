public import ISO_9945_Core

extension ISO_9945.Utility {

    public struct Name: Hashable, Sendable {

        public let rawValue: String

        public init(_ rawValue: String) throws(ISO_9945.Utility.Name.Error) {
            try Self.validate(rawValue)
            self.rawValue = rawValue
        }

        public init(unchecked rawValue: String) {
            self.rawValue = rawValue
        }
    }
}

extension ISO_9945.Utility.Name {

    public static let length = 2...9

    public static func validate(_ rawValue: String) throws(ISO_9945.Utility.Name.Error) {
        guard Self.length.contains(rawValue.count) else {
            throw .invalidLength(rawValue.count)
        }
        for character in rawValue where !Self.isPortable(character) {
            throw .invalidCharacter(character)
        }
    }

    public static func isPortable(_ character: Character) -> Bool {
        guard let scalar = character.asciiValue else { return false }
        return (0x61...0x7A).contains(scalar) || (0x30...0x39).contains(scalar)
    }
}

extension ISO_9945.Utility.Name: CustomStringConvertible {

    public var description: String {
        rawValue
    }
}
