import ISO_9945_Core
import ISO_9945_Utility
import Testing

extension ISO_9945.Utility.Operand {
    @Suite
    struct Test {
        @Suite struct Unit {}
        @Suite struct `Edge Case` {}
    }
}

extension ISO_9945.Utility.Operand.Test.Unit {

    @Test(arguments: ["file.txt", "", " ", "  leading and trailing  ", "\t\n", "naïve 日本語 🦀", "-", "--", "-l", "--verbose", "a=b,c;d"])
    func `an operand round-trips through its description`(_ text: String) {
        let operand = ISO_9945.Utility.Operand(text)

        #expect(operand.description == text)
        #expect(lossless(ISO_9945.Utility.Operand.self, from: operand.description) == operand)
    }

    @Test
    func `an operand round-trips as a generic lossless value`() {
        let operand = ISO_9945.Utility.Operand("--")

        #expect(lossless(ISO_9945.Utility.Operand.self, from: operand.description) == operand)
    }
}

extension ISO_9945.Utility.Operand.Test.`Edge Case` {

    @Test
    func `an empty operand keeps its empty raw value`() {
        let operand = ISO_9945.Utility.Operand("")

        #expect(operand.rawValue.isEmpty)
        #expect(operand.description.isEmpty)
    }

    @Test
    func `an option-looking operand stays an operand`() {
        let operand = ISO_9945.Utility.Operand("-l")

        #expect(operand.rawValue == "-l")
        #expect(operand.requiresDelimiter)
    }
}

private func lossless<Value: LosslessStringConvertible>(_: Value.Type, from description: String) -> Value? {
    Value(description)
}
