public import ISO_9945_Core

extension ISO_9945.Utility.Option {

    public enum Error: Swift.Error, Equatable, Sendable {
        case invalidCharacter(Character)
    }
}
