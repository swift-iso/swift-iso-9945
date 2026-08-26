import ISO_9945_Kernel
import Tagged_Standard_Library_Integration
import Testing

extension ISO_9945.Kernel.File.Clone.Result {
    @Suite
    struct Test {
        @Suite struct Unit {}
        @Suite struct EdgeCase {}
    }
}

extension ISO_9945.Kernel.File.Clone.Result.Test.Unit {
    @Test
    func `reflinked case exists`() {
        let result = ISO_9945.Kernel.File.Clone.Result.reflinked
        if case .reflinked = result {

        } else {
            Issue.record("Expected .reflinked case")
        }
    }

    @Test
    func `copied case exists`() {
        let result = ISO_9945.Kernel.File.Clone.Result.copied
        if case .copied = result {

        } else {
            Issue.record("Expected .copied case")
        }
    }
}

extension ISO_9945.Kernel.File.Clone.Result.Test.Unit {
    @Test
    func `Result is Sendable`() {
        let result: any Sendable = ISO_9945.Kernel.File.Clone.Result.reflinked
        #expect(result is ISO_9945.Kernel.File.Clone.Result)
    }

    @Test
    func `Result is Equatable`() {
        let a = ISO_9945.Kernel.File.Clone.Result.reflinked
        let b = ISO_9945.Kernel.File.Clone.Result.reflinked
        let c = ISO_9945.Kernel.File.Clone.Result.copied
        #expect(a == b)
        #expect(a != c)
    }
}

extension ISO_9945.Kernel.File.Clone.Result.Test.EdgeCase {
    @Test
    func `reflinked and copied are distinct`() {
        let reflinked = ISO_9945.Kernel.File.Clone.Result.reflinked
        let copied = ISO_9945.Kernel.File.Clone.Result.copied
        #expect(reflinked != copied)
    }

    @Test
    func `all cases are distinct`() {
        let cases: [ISO_9945.Kernel.File.Clone.Result] = [
            .reflinked,
            .copied,
        ]

        for i in 0..<cases.count {
            for j in (i + 1)..<cases.count {
                #expect(cases[i] != cases[j])
            }
        }
    }
}
