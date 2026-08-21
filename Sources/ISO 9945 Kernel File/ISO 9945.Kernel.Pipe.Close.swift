extension ISO_9945.Kernel.Pipe {

    public enum Close: Sendable {}
}

extension ISO_9945.Kernel.Pipe.Close {

    public static func write(
        _ descriptors: consuming ISO_9945.Kernel.Pipe.Descriptors
    ) throws(ISO_9945.Kernel.Close.Error) -> ISO_9945.Kernel.Descriptor {
        try descriptors.map {
            (
                pair: consuming Pair<ISO_9945.Kernel.Descriptor, ISO_9945.Kernel.Descriptor>
            ) throws(ISO_9945.Kernel.Close.Error) -> ISO_9945.Kernel.Descriptor in
            try pair.apply {
                (
                    read: consuming ISO_9945.Kernel.Descriptor,
                    write: consuming ISO_9945.Kernel.Descriptor
                ) throws(ISO_9945.Kernel.Close.Error) -> ISO_9945.Kernel.Descriptor in
                try ISO_9945.Kernel.Close.close(write)
                return read
            }
        }.underlying
    }

    public static func read(
        _ descriptors: consuming ISO_9945.Kernel.Pipe.Descriptors
    ) throws(ISO_9945.Kernel.Close.Error) -> ISO_9945.Kernel.Descriptor {
        try descriptors.map {
            (
                pair: consuming Pair<ISO_9945.Kernel.Descriptor, ISO_9945.Kernel.Descriptor>
            ) throws(ISO_9945.Kernel.Close.Error) -> ISO_9945.Kernel.Descriptor in
            try pair.apply {
                (
                    read: consuming ISO_9945.Kernel.Descriptor,
                    write: consuming ISO_9945.Kernel.Descriptor
                ) throws(ISO_9945.Kernel.Close.Error) -> ISO_9945.Kernel.Descriptor in
                try ISO_9945.Kernel.Close.close(read)
                return write
            }
        }.underlying
    }
}
