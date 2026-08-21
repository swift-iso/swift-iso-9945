extension ISO_9945.Kernel.Socket.Address {

    public typealias Length = Tagged<ISO_9945.Kernel.Socket.Address, Cardinal>
}

extension Tagged where Tag == ISO_9945.Kernel.Socket.Address, Underlying == Cardinal {

    @inlinable
    public init(_ socklen: UInt32) {
        self.init(UInt(socklen))
    }
}
