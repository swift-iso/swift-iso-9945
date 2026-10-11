import Either

extension ISO_9945.Kernel.File.Handle {

    public borrowing func read(
        into buffer: UnsafeMutableRawBufferPointer
    ) throws(Either<ISO_9945.Kernel.File.Handle.Error, Interrupt>) -> Int {
        do throws(ISO_9945.Kernel.IO.Read.Error) {
            return try unsafe ISO_9945.Kernel.IO.Read.read(descriptor, into: buffer)
        } catch {
            if error.code.isInterrupted {
                throw .right(.occurred)
            }
            throw .left(ISO_9945.Kernel.File.Handle.Error(from: error, operation: .read))
        }
    }

    public borrowing func pread(
        into buffer: UnsafeMutableRawBufferPointer,
        at offset: ISO_9945.Kernel.File.Offset
    ) throws(Either<ISO_9945.Kernel.File.Handle.Error, Interrupt>) -> Int {
        do throws(ISO_9945.Kernel.IO.Read.Error) {
            return try unsafe ISO_9945.Kernel.IO.Read.pread(descriptor, into: buffer, at: offset)
        } catch {
            if error.code.isInterrupted {
                throw .right(.occurred)
            }
            throw .left(ISO_9945.Kernel.File.Handle.Error(from: error, operation: .read))
        }
    }
}

extension ISO_9945.Kernel.File.Handle {

    public borrowing func read(
        into span: inout MutableSpan<Byte>
    ) throws(Either<ISO_9945.Kernel.File.Handle.Error, Interrupt>) -> Int {
        do throws(ISO_9945.Kernel.IO.Read.Error) {
            return try ISO_9945.Kernel.IO.Read.read(descriptor, into: &span)
        } catch {
            if error.code.isInterrupted {
                throw .right(.occurred)
            }
            throw .left(ISO_9945.Kernel.File.Handle.Error(from: error, operation: .read))
        }
    }

    public borrowing func pread(
        into span: inout MutableSpan<Byte>,
        at offset: ISO_9945.Kernel.File.Offset
    ) throws(Either<ISO_9945.Kernel.File.Handle.Error, Interrupt>) -> Int {
        do throws(ISO_9945.Kernel.IO.Read.Error) {
            return try ISO_9945.Kernel.IO.Read.pread(descriptor, into: &span, at: offset)
        } catch {
            if error.code.isInterrupted {
                throw .right(.occurred)
            }
            throw .left(ISO_9945.Kernel.File.Handle.Error(from: error, operation: .read))
        }
    }
}
