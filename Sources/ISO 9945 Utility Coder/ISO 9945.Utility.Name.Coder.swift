#if Coder
public import Coder
public import ISO_9945_Core
public import ISO_9945_Utility
import Parser
import Serializer

extension ISO_9945.Utility.Name {

    public struct Coder: ISO_9945.Utility.Coding<
        ISO_9945.Utility.Name,
        ISO_9945.Utility.Name.Coder.Error
    > {

        public init() {}

        public borrowing func parse(
            _ input: inout ArraySlice<Swift.String>
        ) throws(ISO_9945.Utility.Name.Coder.Error) -> ISO_9945.Utility.Name {
            guard let word = input.popFirst() else { throw .absent }
            do throws(ISO_9945.Utility.Name.Error) {
                return try ISO_9945.Utility.Name(word)
            } catch {
                throw .invalid(error)
            }
        }

        public borrowing func serialize(
            _ output: ISO_9945.Utility.Name,
            into buffer: inout [Swift.String]
        ) throws(ISO_9945.Utility.Name.Coder.Error) {
            do throws(ISO_9945.Utility.Name.Error) {
                try ISO_9945.Utility.Name.validate(output.rawValue)
            } catch {
                throw .invalid(error)
            }
            buffer.append(output.rawValue)
        }
    }
}
#endif
