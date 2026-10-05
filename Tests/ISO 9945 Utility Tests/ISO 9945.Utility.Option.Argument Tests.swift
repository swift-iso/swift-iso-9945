import ISO_9945_Core
import ISO_9945_Utility
import Testing

extension ISO_9945.Utility.Option.Argument {
    @Suite
    struct Test {
        @Suite struct Unit {}
        @Suite struct `Edge Case` {}
    }
}

extension ISO_9945.Utility.Option.Argument.Test.Unit {

    @Test(arguments: ["3", "", " ", "  leading and trailing  ", "\t\n", "naïve 日本語 🦀", "-", "--", "-l", "--verbose", "a=b,c;d"])
    func `an option argument round-trips through its description`(_ text: String) {
        let argument = ISO_9945.Utility.Option.Argument(text)

        #expect(argument.description == text)
        #expect(lossless(ISO_9945.Utility.Option.Argument.self, from: argument.description) == argument)
    }

    @Test
    func `an option argument round-trips as a generic lossless value`() {
        let argument = ISO_9945.Utility.Option.Argument("-x")

        #expect(lossless(ISO_9945.Utility.Option.Argument.self, from: argument.description) == argument)
    }
}

extension ISO_9945.Utility.Option.Argument.Test.`Edge Case` {

    @Test
    func `an empty option argument keeps its empty raw value`() {
        let argument = ISO_9945.Utility.Option.Argument("")

        #expect(argument.rawValue.isEmpty)
        #expect(argument.description.isEmpty)
    }
}

private func lossless<Value: LosslessStringConvertible>(_: Value.Type, from description: String) -> Value? {
    Value(description)
}
