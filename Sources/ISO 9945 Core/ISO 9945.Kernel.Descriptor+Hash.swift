import Hash_Primitives

extension ISO_9945.Kernel.Descriptor: Hash.`Protocol` {
    @inlinable
    public borrowing func hash(into hasher: inout Hasher) {
        _raw.hash(into: &hasher)
    }
}
