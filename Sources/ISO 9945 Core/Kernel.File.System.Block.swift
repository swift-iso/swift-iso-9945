internal import Cardinal

extension ISO_9945.Kernel.File.System {

    public enum Block {}
}

extension ISO_9945.Kernel.File.System.Block {

    public typealias Size = Magnitude<ISO_9945.Kernel.File.System.Block>.Value<UInt64>
}

extension ISO_9945.Kernel.File.System.Block.Size {

    public static let sector512: Self = Self(512)

    public static let page4096: Self = Self(4096)
}

extension ISO_9945.Kernel.File.System.Block {

    public typealias Count = Tagged<ISO_9945.Kernel.File.System.Block, Cardinal>
}
