#if Coder
public import ISO_9945_Core
public import ISO_9945_Utility

extension ISO_9945.Utility.Name.Coder {

    public enum Error: Swift.Error, Equatable {
        case absent
        case invalid(ISO_9945.Utility.Name.Error)
    }
}
#endif
