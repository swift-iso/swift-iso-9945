#if Coder
public import Coder
public import ISO_9945_Core
public import ISO_9945_Utility

extension ISO_9945.Utility {

    public typealias Coding<Output: ~Copyable & ~Escapable, Failure: Swift.Error> =
        Coder::Coding<ArraySlice<Swift.String>, Output, [Swift.String], Failure>
}
#endif
