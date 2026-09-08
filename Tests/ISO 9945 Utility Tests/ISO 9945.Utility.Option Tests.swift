import ISO_9945_Core
import ISO_9945_Utility
import Testing

extension ISO_9945.Utility.Option {
    @Suite
    struct Test {
        @Suite struct Unit {}
        @Suite struct `Edge Case` {}
    }
}

extension ISO_9945.Utility.Option.Test.Unit {

    @Test
    func `an option is a single alphanumeric character`() throws {
        let option = try ISO_9945.Utility.Option("l")

        #expect(option.name == "l")
        #expect(option.argument == nil)
    }

    @Test
    func `an option carries its option argument`() throws {
        let option = try ISO_9945.Utility.Option("l", argument: .init("3"))

        #expect(option.argument == ISO_9945.Utility.Option.Argument("3"))
        #expect(option.argument?.description == "3")
    }

    @Test
    func `a grouped option run is a sequence of options`() throws {
        let group = try ["a", "b", "c"].map { try ISO_9945.Utility.Option(Character($0)) }

        #expect(group.map(\.name) == ["a", "b", "c"])
    }
}

extension ISO_9945.Utility.Option.Test.`Edge Case` {

    @Test
    func `a hyphen is not an option name`() {
        #expect(throws: ISO_9945.Utility.Option.Error.invalidCharacter("-")) {
            try ISO_9945.Utility.Option("-")
        }
    }

    @Test
    func `a non ascii character is not an option name`() {
        #expect(throws: ISO_9945.Utility.Option.Error.invalidCharacter("é")) {
            try ISO_9945.Utility.Option("é")
        }
    }
}
