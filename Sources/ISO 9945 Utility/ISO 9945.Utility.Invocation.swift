public import ISO_9945_Core

extension ISO_9945.Utility {

    public struct Invocation: Hashable, Sendable {

        public let name: Name

        public let options: [Option]

        public let operands: [Operand]

        public init(
            name: Name,
            options: [Option] = [],
            operands: [Operand] = []
        ) {
            self.name = name
            self.options = options
            self.operands = operands
        }
    }
}

extension ISO_9945.Utility.Invocation {

    public var arguments: [ISO_9945.Utility.Argument] {
        var arguments = options.map { ISO_9945.Utility.Argument.option($0) }
        if operands.first?.requiresDelimiter == true {
            arguments.append(.endOfOptions)
        }
        arguments.append(contentsOf: operands.map { ISO_9945.Utility.Argument.operand($0) })
        return arguments
    }
}
