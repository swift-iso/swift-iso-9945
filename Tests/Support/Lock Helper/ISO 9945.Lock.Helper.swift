#if os(macOS) || os(Linux)

    import Path
    import Error
    import ISO_9945_Kernel
    @_spi(Syscall) import ISO_9945_Kernel_Lock
    @_spi(Syscall) import ISO_9945_Kernel_File

    @main
    struct LockHelper {
        static func main() {
            let args = CommandLine.arguments

            guard args.count >= 3 else {
                print("Usage: iso-9945-lock-helper <path> <milliseconds>")
                ISO_9945.Kernel.Process.Exit.now(1)
            }

            let path = args[1]
            guard let milliseconds = Int(args[2]), milliseconds > 0 else {
                print("Error: milliseconds must be a positive integer")
                ISO_9945.Kernel.Process.Exit.now(1)
            }

            do {
                try Path.scope(path) { kernelPath in

                    let fd = try ISO_9945.Kernel.File.Open.open(
                        path: kernelPath,
                        mode: .readWrite,
                        options: [],
                        permissions: 0
                    )

                    try ISO_9945.Kernel.Lock.lock(fd: fd._rawValue, range: .file, kind: .exclusive)
                    defer { try? ISO_9945.Kernel.Lock.unlock(fd: fd._rawValue, range: .file) }

                    print("LOCKED")

                    System.sleep(.milliseconds(milliseconds))
                }

                print("RELEASED")
                ISO_9945.Kernel.Process.Exit.now(0)
            } catch {
                print("Error: \(error)")
                ISO_9945.Kernel.Process.Exit.now(1)
            }
        }
    }

#endif
