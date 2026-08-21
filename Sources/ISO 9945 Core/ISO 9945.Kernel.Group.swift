public import Tagged_Primitives

extension ISO_9945.Kernel {

    public enum Group: Sendable {}
}

extension ISO_9945.Kernel.Group {

    public typealias ID = Tagged<ISO_9945.Kernel.Group, UInt32>
}

extension Tagged where Tag == ISO_9945.Kernel.Group, Underlying == UInt32 {

    public static var root: Self { .zero }
}
