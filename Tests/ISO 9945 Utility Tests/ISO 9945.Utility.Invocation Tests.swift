import ISO_9945_Core
import ISO_9945_Utility
import Testing

extension ISO_9945.Utility.Invocation {
    @Suite
    struct Test {
        @Suite struct Unit {}
        @Suite struct `Edge Case` {}
    }
}

extension ISO_9945.Utility.Invocation.Test.Unit {

    @Test
    func `an invocation records the name the options and the operands in order`() throws {
        let invocation = ISO_9945.Utility.Invocation(
            name: try .init("counter"),
            options: [try .init("l", argument: .init("3"))],
            operands: [.init("increment")]
        )

        #expect(invocation.name.rawValue == "counter")
        #expect(invocation.options.map(\.name) == ["l"])
        #expect(invocation.operands.map(\.rawValue) == ["increment"])
    }

    @Test
    func `the argument view lists the options then the operands`() throws {
        let invocation = ISO_9945.Utility.Invocation(
            name: try .init("greeting"),
            operands: [.init("greet"), .init("Ada")]
        )

        #expect(
            invocation.arguments == [
                .operand(.init("greet")),
                .operand(.init("Ada")),
            ]
        )
    }
}

extension ISO_9945.Utility.Invocation.Test.`Edge Case` {

    @Test
    func `an operand that reads as an option requires the end of options delimiter`() throws {
        let invocation = ISO_9945.Utility.Invocation(
            name: try .init("counter"),
            operands: [.init("-l")]
        )

        #expect(ISO_9945.Utility.Operand("-l").requiresDelimiter)
        #expect(invocation.arguments == [.endOfOptions, .operand(.init("-l"))])
    }

    @Test
    func `a lone hyphen operand needs no delimiter`() throws {
        let invocation = ISO_9945.Utility.Invocation(
            name: try .init("counter"),
            operands: [.init("-")]
        )

        #expect(!ISO_9945.Utility.Operand("-").requiresDelimiter)
        #expect(invocation.arguments == [.operand(.init("-"))])
    }
}
