#if Coder
import Coder
import ISO_9945_Core
import ISO_9945_Utility
import ISO_9945_Utility_Coder
import Parser
import Serializer
import Testing

@Suite
struct `ISO 9945 Utility Coder` {

    @Test
    func `a utility invocation reads its name then its operands`() throws(any Swift.Error) {
        var arguments: ArraySlice<String> = ["greeting", "greet", "Ada"]

        let invocation = try ISO_9945.Utility.Invocation.coder.parse(&arguments)

        #expect(invocation.name.rawValue == "greeting")
        #expect(invocation.options.isEmpty)
        #expect(invocation.operands.map(\.rawValue) == ["greet", "Ada"])
        #expect(arguments.isEmpty)
    }

    @Test
    func `options precede operands so a word after the first operand is an operand`() throws(any Swift.Error) {
        var arguments: ArraySlice<String> = ["counter", "increment", "-l", "3"]

        let invocation = try ISO_9945.Utility.Invocation.coder.parse(&arguments)

        #expect(invocation.options.isEmpty)
        #expect(invocation.operands.map(\.rawValue) == ["increment", "-l", "3"])
    }

    @Test
    func `a subcommand is the invocation that follows the utility name`() throws(any Swift.Error) {
        var arguments: ArraySlice<String> = ["counter", "increment", "-l", "3"]

        let utility = try ISO_9945.Utility.Name.coder.parse(&arguments)
        let invocation = try ISO_9945.Utility.Invocation.Coder(arguments: ["l"]).parse(&arguments)

        #expect(utility.rawValue == "counter")
        #expect(invocation.name.rawValue == "increment")
        #expect(invocation.options == [try .init("l", argument: .init("3"))])
        #expect(invocation.operands.isEmpty)
    }

    @Test
    func `a grouped option run expands to one option per character`() throws(any Swift.Error) {
        var arguments: ArraySlice<String> = ["update", "-abc"]

        let invocation = try ISO_9945.Utility.Invocation.coder.parse(&arguments)

        #expect(invocation.options.map(\.name) == ["a", "b", "c"])
        #expect(invocation.options.allSatisfy { $0.argument == nil })
    }

    @Test
    func `a group ends with the option that takes an option argument`() throws(any Swift.Error) {
        var arguments: ArraySlice<String> = ["update", "-abl", "3"]

        let invocation = try ISO_9945.Utility.Invocation.Coder(arguments: ["l"]).parse(&arguments)

        #expect(invocation.options.map(\.name) == ["a", "b", "l"])
        #expect(invocation.options.last?.argument == ISO_9945.Utility.Option.Argument("3"))
    }

    @Test
    func `an option argument is accepted attached to its option`() throws(any Swift.Error) {
        var arguments: ArraySlice<String> = ["update", "-l3"]

        let invocation = try ISO_9945.Utility.Invocation.Coder(arguments: ["l"]).parse(&arguments)

        #expect(invocation.options == [try .init("l", argument: .init("3"))])
    }

    @Test
    func `an attached option argument is written back as a separate word`() throws(any Swift.Error) {
        var arguments: ArraySlice<String> = ["update", "-l3"]
        let coder = ISO_9945.Utility.Invocation.Coder(arguments: ["l"])

        let invocation = try coder.parse(&arguments)
        var written: [String] = []
        try coder.serialize(invocation, into: &written)

        #expect(written == ["update", "-l", "3"])
    }

    @Test
    func `the end of options delimiter ends the option run`() throws(any Swift.Error) {
        var arguments: ArraySlice<String> = ["update", "-a", "--", "-l"]

        let invocation = try ISO_9945.Utility.Invocation.coder.parse(&arguments)

        #expect(invocation.options.map(\.name) == ["a"])
        #expect(invocation.operands.map(\.rawValue) == ["-l"])
    }

    @Test
    func `an operand that reads as an option round trips through the delimiter`() throws(any Swift.Error) {
        let vector = ["update", "-a", "--", "-l"]
        var arguments: ArraySlice<String> = vector[...]

        let invocation = try ISO_9945.Utility.Invocation.coder.parse(&arguments)
        var written: [String] = []
        try ISO_9945.Utility.Invocation.coder.serialize(invocation, into: &written)

        #expect(written == vector)
    }

    @Test
    func `an argument vector round trips through the codable entry point`() throws(any Swift.Error) {
        let vector = ["greeting", "greet", "Ada"]
        var arguments: ArraySlice<String> = vector[...]

        let invocation = try ISO_9945.Utility.Invocation.coder.parse(&arguments)
        var written: [String] = []
        try invocation.encode(into: &written)

        #expect(written == vector)
    }

    @Test
    func `a utility name of ten characters violates the length guideline`() {
        var arguments: ArraySlice<String> = ["increments"]

        #expect(throws: ISO_9945.Utility.Invocation.Coder.Error.name(.invalid(.invalidLength(10)))) {
            try ISO_9945.Utility.Invocation.coder.parse(&arguments)
        }
    }

    @Test
    func `an uppercase utility name violates the portable character guideline`() {
        var arguments: ArraySlice<String> = ["Counter"]

        #expect(throws: ISO_9945.Utility.Invocation.Coder.Error.name(.invalid(.invalidCharacter("C")))) {
            try ISO_9945.Utility.Invocation.coder.parse(&arguments)
        }
    }

    @Test
    func `an empty argument vector has no utility name`() {
        var arguments: ArraySlice<String> = []

        #expect(throws: ISO_9945.Utility.Invocation.Coder.Error.name(.absent)) {
            try ISO_9945.Utility.Invocation.coder.parse(&arguments)
        }
    }

    @Test
    func `an option name that is not alphanumeric is rejected`() {
        var arguments: ArraySlice<String> = ["update", "-!"]

        #expect(
            throws: ISO_9945.Utility.Invocation.Coder.Error.option(.invalid(.invalidCharacter("!")))
        ) {
            try ISO_9945.Utility.Invocation.coder.parse(&arguments)
        }
    }

    @Test
    func `an option that takes an option argument is rejected without one`() {
        var arguments: ArraySlice<String> = ["update", "-l"]

        #expect(throws: ISO_9945.Utility.Invocation.Coder.Error.option(.missingArgument("l"))) {
            try ISO_9945.Utility.Invocation.Coder(arguments: ["l"]).parse(&arguments)
        }
    }

    @Test
    func `a lone hyphen is an operand and not an option`() throws(any Swift.Error) {
        var arguments: ArraySlice<String> = ["update", "-"]

        let invocation = try ISO_9945.Utility.Invocation.coder.parse(&arguments)

        #expect(invocation.options.isEmpty)
        #expect(invocation.operands.map(\.rawValue) == ["-"])
    }

    @Test
    func `a utility name is codable on its own`() throws(any Swift.Error) {
        var arguments: ArraySlice<String> = ["counter", "increment"]

        let name = try ISO_9945.Utility.Name.coder.parse(&arguments)
        var written: [String] = []
        try name.encode(into: &written)

        #expect(written == ["counter"])
        #expect(arguments == ["increment"])
    }

    @Test
    func `an operand is codable on its own`() throws(any Swift.Error) {
        var arguments: ArraySlice<String> = ["Ada"]

        let operand = try ISO_9945.Utility.Operand.coder.parse(&arguments)
        var written: [String] = []
        try operand.encode(into: &written)

        #expect(operand.rawValue == "Ada")
        #expect(written == ["Ada"])
    }
}
#endif
