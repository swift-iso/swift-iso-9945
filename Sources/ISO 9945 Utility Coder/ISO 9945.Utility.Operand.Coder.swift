#if Coder
public import Coder
public import ISO_9945_Core
public import ISO_9945_Utility
import Parser
import Serializer

extension ISO_9945.Utility.Operand {

    public struct Coder: ISO_9945.Utility.Coding<
        ISO_9945.Utility.Operand,
        ISO_9945.Utility.Operand.Coder.Error
    > {

        public init() {}

        public borrowing func parse(
            _ input: inout ArraySlice<Swift.String>
        ) throws(ISO_9945.Utility.Operand.Coder.Error) -> ISO_9945.Utility.Operand {
            guard let word = input.popFirst() else { throw .absent }
            return .init(word)
        }

        public borrowing func serialize(
            _ output: ISO_9945.Utility.Operand,
            into buffer: inout [Swift.String]
        ) throws(ISO_9945.Utility.Operand.Coder.Error) {
            buffer.append(output.rawValue)
        }
    }
}
#endif
