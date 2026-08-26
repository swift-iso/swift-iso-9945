public import Tagged

extension ISO_9945.Kernel {

    public enum User: Sendable {}
}

extension ISO_9945.Kernel.User {

    public typealias ID = Tagged<ISO_9945.Kernel.User, UInt32>
}

extension Tagged where Tag == ISO_9945.Kernel.User, Underlying == UInt32 {

    public static var root: Self { .zero }
}
