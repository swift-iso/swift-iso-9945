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
