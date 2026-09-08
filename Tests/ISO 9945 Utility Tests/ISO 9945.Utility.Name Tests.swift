import ISO_9945_Core
import ISO_9945_Utility
import Testing

extension ISO_9945.Utility.Name {
    @Suite
    struct Test {
        @Suite struct Unit {}
        @Suite struct `Edge Case` {}
    }
}

extension ISO_9945.Utility.Name.Test.Unit {

    @Test
    func `a utility name of lowercase letters and digits is accepted`() throws {
        let name = try ISO_9945.Utility.Name("counter")

        #expect(name.rawValue == "counter")
        #expect(name.description == "counter")
    }

    @Test
    func `digits are part of the portable utility name set`() throws {
        let name = try ISO_9945.Utility.Name("m4")

        #expect(name.rawValue == "m4")
    }
}

extension ISO_9945.Utility.Name.Test.`Edge Case` {

    @Test
    func `a one character utility name violates the length guideline`() {
        #expect(throws: ISO_9945.Utility.Name.Error.invalidLength(1)) {
            try ISO_9945.Utility.Name("c")
        }
    }

    @Test
    func `a ten character utility name violates the length guideline`() {
        #expect(throws: ISO_9945.Utility.Name.Error.invalidLength(10)) {
            try ISO_9945.Utility.Name("increments")
        }
    }

    @Test
    func `an uppercase letter is outside the portable utility name set`() {
        #expect(throws: ISO_9945.Utility.Name.Error.invalidCharacter("C")) {
            try ISO_9945.Utility.Name("Counter")
        }
    }

    @Test
    func `a hyphen is outside the portable utility name set`() {
        #expect(throws: ISO_9945.Utility.Name.Error.invalidCharacter("-")) {
            try ISO_9945.Utility.Name("my-tool")
        }
    }
}
