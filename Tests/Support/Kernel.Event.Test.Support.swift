import Error
public import ISO_9945_Kernel
import Path

extension ISO_9945.Kernel.Event {

    public enum Test {

        public struct PipeError: Swift.Error, Sendable {
            public init() {}
        }

        public static func makePipe() throws -> ISO_9945.Kernel.Pipe.Descriptors {
            do {
                return try ISO_9945.Kernel.Pipe.pipe()
            } catch {
                throw PipeError()
            }
        }

        public static func writeByte(_ fd: borrowing ISO_9945.Kernel.Descriptor, value: UInt8 = 1) {
            var byte = value
            _ = withUnsafeBytes(of: &byte) { buffer in
                try? unsafe ISO_9945.Kernel.IO.Write.write(fd, from: buffer)
            }
        }

        public static func readDrain(_ fd: borrowing ISO_9945.Kernel.Descriptor) {
            var byte: UInt8 = 0
            _ = withUnsafeMutableBytes(of: &byte) { buffer in
                try? unsafe ISO_9945.Kernel.IO.Read.read(fd, into: buffer)
            }
        }
    }
}
