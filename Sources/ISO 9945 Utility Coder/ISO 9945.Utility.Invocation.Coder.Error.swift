#if Coder
public import ISO_9945_Core
public import ISO_9945_Utility

extension ISO_9945.Utility.Invocation.Coder {

    public enum Error: Swift.Error, Equatable {
        case name(ISO_9945.Utility.Name.Coder.Error)
        case option(ISO_9945.Utility.Option.Coder.Error)
        case operand(ISO_9945.Utility.Operand.Coder.Error)
    }
}
#endif
