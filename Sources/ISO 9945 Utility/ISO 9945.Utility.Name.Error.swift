public import ISO_9945_Core

extension ISO_9945.Utility.Name {

    public enum Error: Swift.Error, Equatable, Sendable {
        case invalidLength(Int)
        case invalidCharacter(Character)
    }
}
