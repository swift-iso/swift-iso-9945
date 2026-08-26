#if !os(Windows)

    extension Terminal.Stream.Interactive {

        public func callAsFunction() -> Bool {
            ISO_9945.Kernel.TTY.isTTY(fd: stream.rawValue)
        }
    }

    extension Terminal.Size {

        public static func query(stream: Terminal.Stream = .stdout) throws(Terminal.Error) -> Self {
            do throws(Error.Error) {
                let kernelSize = try ISO_9945.Kernel.TTY.Size.query(fd: stream.rawValue)
                return Terminal.Size(rows: kernelSize.rows, columns: kernelSize.columns)
            } catch let error {
                throw Terminal.Error(operation: .querySize, underlying: .kernel(error))
            }
        }
    }

#endif
