#if Coder
public import Coder
public import ISO_9945_Core
public import ISO_9945_Utility

extension ISO_9945.Utility {

    public protocol Codable: Coder::Coder.Codable
    where
        Coder.Input == ArraySlice<Swift.String>,
        Coder.Buffer == [Swift.String]
    {}
}
#endif
