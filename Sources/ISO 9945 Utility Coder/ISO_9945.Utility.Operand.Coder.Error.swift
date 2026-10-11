#if Coder
public import ISO_9945_Core
public import ISO_9945_Utility

extension ISO_9945.Utility.Operand.Coder {

    public enum Error: Swift.Error, Equatable {
        case absent
    }
}
#endif
