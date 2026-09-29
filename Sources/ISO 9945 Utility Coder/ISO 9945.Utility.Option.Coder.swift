#if Coder
public import Checkpoint
public import Coder
public import Cursor
public import Cursor
public import ISO_9945_Core
public import ISO_9945_Utility
import Parser
import Serializer

extension ISO_9945.Utility.Option {

    public struct Coder: ISO_9945.Utility.Coding<
        [ISO_9945.Utility.Option],
        ISO_9945.Utility.Option.Coder.Error
    > {

        public let arguments: Set<Character>

        public init(arguments: Set<Character> = []) {
            self.arguments = arguments
        }

        public borrowing func parse(
            _ input: inout ArraySlice<Swift.String>
        ) throws(ISO_9945.Utility.Option.Coder.Error) -> [ISO_9945.Utility.Option] {
            let mark = input.checkpoint
            guard let word = input.popFirst() else { throw .absent }
            guard
                word.count > 1,
                word.first == ISO_9945.Utility.Option.delimiter,
                word != ISO_9945.Utility.Argument.delimiter
            else {
                input.seek(to: mark)
                throw .absent
            }

            let characters = Array(word.dropFirst())
            var options: [ISO_9945.Utility.Option] = []
            var index = 0

            while index < characters.count {
                let name = characters[index]
                do throws(ISO_9945.Utility.Option.Error) {
                    try ISO_9945.Utility.Option.validate(name)
                } catch {
                    input.seek(to: mark)
                    throw .invalid(error)
                }

                guard arguments.contains(name) else {
                    options.append(.init(unchecked: name))
                    index += 1
                    continue
                }

                let attached = Swift.String(characters[(index + 1)...])
                if attached.isEmpty {
                    guard let following = input.popFirst() else {
                        input.seek(to: mark)
                        throw .missingArgument(name)
                    }
                    options.append(.init(unchecked: name, argument: .init(following)))
                } else {
                    options.append(.init(unchecked: name, argument: .init(attached)))
                }
                index = characters.count
            }

            return options
        }

        public borrowing func serialize(
            _ output: [ISO_9945.Utility.Option],
            into buffer: inout [Swift.String]
        ) throws(ISO_9945.Utility.Option.Coder.Error) {
            for option in output {
                do throws(ISO_9945.Utility.Option.Error) {
                    try ISO_9945.Utility.Option.validate(option.name)
                } catch {
                    throw .invalid(error)
                }

                switch (arguments.contains(option.name), option.argument) {
                case (true, .none):
                    throw .missingArgument(option.name)

                case (false, .some):
                    throw .unexpectedArgument(option.name)

                case (false, .none):
                    buffer.append("\(ISO_9945.Utility.Option.delimiter)\(option.name)")

                case (true, .some(let argument)):
                    buffer.append("\(ISO_9945.Utility.Option.delimiter)\(option.name)")
                    buffer.append(argument.rawValue)
                }
            }
        }
    }
}

extension ISO_9945.Utility.Option {

    public static var coder: ISO_9945.Utility.Option.Coder {
        .init()
    }
}
#endif
