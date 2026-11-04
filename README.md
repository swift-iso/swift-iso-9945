# swift-iso-9945

Use this package when you need to make POSIX system calls from Swift on macOS or Linux with typed errors and owned descriptors: files, directories, locks, pipes, sockets, memory maps, signals, processes, threads, clocks and the environment. Start from `ISO_9945.Kernel.Descriptor` and the namespaces under `ISO_9945.Kernel`; the `ISO 9945 Kernel` product brings them all in. For shell-style pattern matching use `ISO_9945.Glob`, and for POSIX utility argument syntax use `ISO_9945.Utility.Invocation`.

## Laws

- Each call makes one attempt and reports what the kernel said. A call a signal interrupts (EINTR) is not retried. `ISO_9945.Kernel.File.Handle` reads and writes report it as the `Interrupt` side of the thrown `Either`, and `ISO_9945.Kernel.Thread.sleep(_:)` returns the time left to sleep. The one exception is `Terminal.Stream.Write`, which retries until every byte is written.
- `ISO_9945.Kernel.Descriptor` closes itself when it is destroyed and ignores any error from that close. `ISO_9945.Kernel.Close.close(_:)` consumes the descriptor, so it is never closed twice, even when the close reports an error.
- A negative descriptor never reaches the kernel. Closing, reading or writing it fails as an invalid handle.
- Reading into or writing from an empty buffer returns 0 without a system call.
- Opening a file with a mode that neither reads nor writes fails with EINVAL before the kernel is called.
- `ISO_9945.Kernel.Directory.Create.create(_:permissions:)` uses `0o755` unless you pass other permissions.
- Locks are POSIX record locks taken with `fcntl`. `ISO_9945.Kernel.Lock.Token` unlocks when it is destroyed and ignores an unlock failure. `ISO_9945.Kernel.Lock.Token.release()` can be called more than once.
- A byte range that ends where it starts locks nothing and succeeds. A range that ends before it starts fails. `ISO_9945.Kernel.Lock.Range.bytes(start:length:)` stops at the largest offset instead of overflowing.
- Waiting with a deadline polls with non-blocking attempts, sleeping 1 ms between them and doubling up to 100 ms. The deadline is measured on `Clock.Continuous`. A lock obtained after the deadline has passed is released again and reported as timed out.
- `Clock.Continuous` keeps counting while the machine sleeps: CLOCK_MONOTONIC_RAW on Darwin, CLOCK_BOOTTIME on Linux. `Clock.Suspending` stops: CLOCK_UPTIME_RAW on Darwin, CLOCK_MONOTONIC on Linux. The CPU clocks report zero if the clock can't be read.
- `Time.Zone.Rule.local` reads `TZ` again for every instant, so a change takes effect at once. If the local time can't be computed, it gives UTC.
- `ISO_9945.Kernel.Signal.Send.toGroup(_:pgid:)` refuses process group 1 with EINVAL, since that would signal every process. `ISO_9945.Kernel.Process.Wait.wait(_:options:)` returns nil only when you asked not to hang and no child has changed state.
- `ISO_9945.Kernel.Environment.set(_:to:overwrite:)` and `ISO_9945.Kernel.Environment.unset(_:)` refuse an empty name or a name containing `=` before calling the C library. `ISO_9945.Kernel.Environment.entries()` skips entries that have no `=`.
- Reading a symbolic link's target starts with a 256-byte buffer and doubles it up to 64 KiB. A longer target fails as too long for the buffer. The working directory is read the same way, from 4 KiB up to 1 MiB.
- Paths follow the POSIX grammar. Path text may not be empty or contain NUL or control characters. Components skip empty segments, so `a//b` has two. Appending joins with exactly one separator, and appending an absolute path gives that path. The parent of `/a` is `/`, and the root and a single relative component have none. A path relative to itself is `.`, and relative to a base that is not its prefix it is nil. A prefix must match whole components and be absolute or relative like the path.
- `ISO_9945.Filename` is non-empty and has no `/`, NUL or control character (below 0x20, or 0x7F).
- `ISO_9945.Utility.Name` is 2 to 9 characters, each a lowercase ASCII letter or a digit. An option name is one ASCII letter or digit.
- `ISO_9945.Utility.Invocation.arguments` puts `--` before the operands only when the first operand starts with `-` and is longer than one character. A lone `-` is an operand.
- `ISO_9945.Utility.Invocation.Coder` expands a grouped run such as `-ab` into one option per character. An option that takes an argument ends the run and takes the rest of the word, or the next word if nothing is left. Options end at `--`, which is dropped, or at the first word that is not an option. Writing an invocation back puts every option argument in its own word.
