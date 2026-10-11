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
