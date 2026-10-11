#if !os(Windows)

    extension Terminal.Stream.Read {

        public func callAsFunction(
            into buffer: UnsafeMutableRawBufferPointer
        ) throws(ISO_9945.Kernel.IO.Read.Error) -> Int {
            try unsafe ISO_9945.Kernel.IO.Read.read(stream, into: buffer)
        }
    }

#endif
