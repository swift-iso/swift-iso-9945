#if Coder
    public import Coder
    public import ISO_9945_Core
    public import ISO_9945_Utility
    public import Parser
    public import Serializer

    extension ISO_9945.Utility {

        public typealias Coding<Output: ~Copyable & ~Escapable, Failure: Swift::Error> =
            Coder::Coding
            & Parsing<ArraySlice<Swift::String>, Output, Failure>
            & Serializing<Output, [Swift::String], Failure>
    }
#endif
