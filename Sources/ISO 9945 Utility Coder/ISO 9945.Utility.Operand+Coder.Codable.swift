#if Coder
public import Coder
public import ISO_9945_Core
public import ISO_9945_Utility

extension ISO_9945.Utility.Operand: ISO_9945.Utility.Codable {

    public static var coder: ISO_9945.Utility.Operand.Coder {
        .init()
    }
}
#endif
