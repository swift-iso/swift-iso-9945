@_spi(Internal) public import Tagged_Primitives

extension ISO_9945.Kernel.Event {

    public typealias ID = Tagged<ISO_9945.Kernel.Event, UInt>
}

extension Tagged where Tag == ISO_9945.Kernel.Event, Underlying == UInt {

    @inlinable
    public init(_ value: Int32) {
        self.init(_unchecked: UInt(bitPattern: Int(value)))
    }
}
