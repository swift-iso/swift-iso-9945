extension ISO_9945.Kernel {
    /// I/O multiplexing via `poll(2)`.
    ///
    /// Monitors multiple file descriptors for readiness events without blocking
    /// on any single descriptor. The fundamental building block for event-driven I/O.
    public enum Poll {}
}
