#if Coder
public import ISO_9945_Core
public import ISO_9945_Utility

extension ISO_9945.Utility.Option.Coder {

    public enum Error: Swift.Error, Equatable {
        case absent
        case invalid(ISO_9945.Utility.Option.Error)
        case missingArgument(Character)
        case unexpectedArgument(Character)
    }
}
#endif
