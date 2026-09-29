#if Coder
public import Coder
public import ISO_9945_Core
public import ISO_9945_Utility

extension ISO_9945.Utility.Name {

    public static var coder: ISO_9945.Utility.Name.Coder {
        .init()
    }
}
#endif
