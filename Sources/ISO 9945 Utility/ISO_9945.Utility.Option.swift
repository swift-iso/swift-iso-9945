public import ISO_9945_Core

extension ISO_9945.Utility {

    public struct Option: Hashable, Sendable {

        public let name: Character

        public let argument: ISO_9945.Utility.Option.Argument?

        public init(
            _ name: Character,
            argument: ISO_9945.Utility.Option.Argument? = nil
        ) throws(ISO_9945.Utility.Option.Error) {
            try Self.validate(name)
            self.name = name
            self.argument = argument
        }

        public init(
            unchecked name: Character,
            argument: ISO_9945.Utility.Option.Argument? = nil
        ) {
            self.name = name
            self.argument = argument
        }
    }
}

extension ISO_9945.Utility.Option {

    public static let delimiter: Character = "-"

    public static func validate(_ name: Character) throws(ISO_9945.Utility.Option.Error) {
        guard Self.isAlphanumeric(name) else {
            throw .invalidCharacter(name)
        }
    }

    public static func isAlphanumeric(_ character: Character) -> Bool {
        guard let scalar = character.asciiValue else { return false }
        return (0x41...0x5A).contains(scalar)
            || (0x61...0x7A).contains(scalar)
            || (0x30...0x39).contains(scalar)
    }
}
