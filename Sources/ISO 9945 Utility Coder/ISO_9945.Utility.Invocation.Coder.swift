#if Coder
public import Coder
public import ISO_9945_Core
public import ISO_9945_Utility
import Parser
import Serializer

extension ISO_9945.Utility.Invocation {

    public struct Coder: ISO_9945.Utility.Coding<
        ISO_9945.Utility.Invocation,
        ISO_9945.Utility.Invocation.Coder.Error
    > {


        public let name: ISO_9945.Utility.Name.Coder

        public let option: ISO_9945.Utility.Option.Coder

        public let operand: ISO_9945.Utility.Operand.Coder

        public init(arguments: Set<Character> = []) {
            self.name = .init()
            self.option = .init(arguments: arguments)
            self.operand = .init()
        }

        public borrowing func parse(
            _ input: inout ArraySlice<Swift.String>
        ) throws(ISO_9945.Utility.Invocation.Coder.Error) -> ISO_9945.Utility.Invocation {
            let name: ISO_9945.Utility.Name
            do throws(ISO_9945.Utility.Name.Coder.Error) {
                name = try self.name.parse(&input)
            } catch {
                throw .name(error)
            }

            var options: [ISO_9945.Utility.Option] = []

            while !input.isEmpty {
                if input.first == ISO_9945.Utility.Argument.delimiter {
                    input.removeFirst()
                    break
                }
                do throws(ISO_9945.Utility.Option.Coder.Error) {
                    options.append(contentsOf: try self.option.parse(&input))
                } catch {
                    guard error == .absent else { throw .option(error) }
                    break
                }
            }

            var operands: [ISO_9945.Utility.Operand] = []
            while !input.isEmpty {
                do throws(ISO_9945.Utility.Operand.Coder.Error) {
                    operands.append(try self.operand.parse(&input))
                } catch {
                    throw .operand(error)
                }
            }

            return .init(name: name, options: options, operands: operands)
        }

        public borrowing func serialize(
            _ output: ISO_9945.Utility.Invocation,
            into buffer: inout [Swift.String]
        ) throws(ISO_9945.Utility.Invocation.Coder.Error) {
            do throws(ISO_9945.Utility.Name.Coder.Error) {
                try self.name.serialize(output.name, into: &buffer)
            } catch {
                throw .name(error)
            }

            for argument in output.arguments {
                switch argument {
                case .option(let value):
                    do throws(ISO_9945.Utility.Option.Coder.Error) {
                        try self.option.serialize([value], into: &buffer)
                    } catch {
                        throw .option(error)
                    }

                case .endOfOptions:
                    buffer.append(ISO_9945.Utility.Argument.delimiter)

                case .operand(let value):
                    do throws(ISO_9945.Utility.Operand.Coder.Error) {
                        try self.operand.serialize(value, into: &buffer)
                    } catch {
                        throw .operand(error)
                    }
                }
            }
        }
    }
}
#endif
