extension ISO_9945.Kernel.File.Direct {

    public enum Capability: Sendable, Equatable {

        case directSupported(Requirements.Alignment)

        case uncachedOnly

        case bufferedOnly
    }
}

extension ISO_9945.Kernel.File.Direct.Capability {

    public var direct: Direct { Direct(capability: self) }

    public struct Direct: Sendable {
        let capability: ISO_9945.Kernel.File.Direct.Capability
    }
}

extension ISO_9945.Kernel.File.Direct.Capability.Direct {

    public var isSupported: Bool {
        if case .directSupported = capability { return true }
        return false
    }
}

extension ISO_9945.Kernel.File.Direct.Capability {

    public var bypass: Bypass { Bypass(capability: self) }

    public struct Bypass: Sendable {
        let capability: ISO_9945.Kernel.File.Direct.Capability
    }
}

extension ISO_9945.Kernel.File.Direct.Capability.Bypass {

    public var isSupported: Bool {
        switch capability {
        case .directSupported, .uncachedOnly:
            return true

        case .bufferedOnly:
            return false
        }
    }
}

extension ISO_9945.Kernel.File.Direct.Capability {

    public var alignment: ISO_9945.Kernel.File.Direct.Requirements.Alignment? {
        if case .directSupported(let alignment) = self {
            return alignment
        }
        return nil
    }
}
