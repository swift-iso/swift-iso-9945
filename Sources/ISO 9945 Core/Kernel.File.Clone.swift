extension ISO_9945.Kernel.File {
    public enum Clone {}
}

extension ISO_9945.Kernel.File.Clone.Capability {

    public static func probeDefault(
        at path: borrowing Path
    ) -> ISO_9945.Kernel.File.Clone.Capability {
        _ = path
        return .none
    }
}

extension ISO_9945.Kernel.File.Clone {

    public enum Metadata {}
}
