#if !os(Windows)

    extension Terminal.Stream.Write {

        @discardableResult
        public func callAsFunction(
            _ bytes: some Swift.Sequence<Byte>
        ) throws(ISO_9945.Kernel.IO.Write.Error) -> Int {
            let array = ContiguousArray<Byte>(bytes)
            return try array.withUnsafeBufferPointer {
                (buffer: UnsafeBufferPointer<Byte>) throws(ISO_9945.Kernel.IO.Write.Error) -> Int in
                let raw = UnsafeRawBufferPointer(buffer)
                return try unsafe write(raw)
            }
        }

        private func write(
            _ raw: UnsafeRawBufferPointer
        ) throws(ISO_9945.Kernel.IO.Write.Error) -> Int {
            var written = 0
            while written < raw.count {
                let remaining = unsafe UnsafeRawBufferPointer(rebasing: raw[written..<raw.count])
                do throws(ISO_9945.Kernel.IO.Write.Error) {
                    let n = try unsafe ISO_9945.Kernel.IO.Write.write(stream, from: remaining)
                    written += n
                } catch let error {
                    if error.code.isInterrupted {
                        continue
                    }
                    throw error
                }
            }
            return written
        }
    }

#endif
