
extension ISO_9945.Kernel.Descriptor: Swift.Equatable {
    @inlinable
    public static func == (
        lhs: borrowing ISO_9945.Kernel.Descriptor,
        rhs: borrowing ISO_9945.Kernel.Descriptor
    ) -> Bool {
        lhs._raw == rhs._raw
    }
}
