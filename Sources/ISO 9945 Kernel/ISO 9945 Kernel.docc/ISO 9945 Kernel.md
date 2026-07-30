# ``ISO_9945_Kernel``

@Metadata {
    @DisplayName("ISO 9945 Kernel")
    @TitleHeading("Swift Standards")
}

Typed Swift bindings for the POSIX (ISO/IEC/IEEE 9945) kernel-facing
system call surface — file, directory, socket, signal, process, thread,
memory, poll, clock, environment, identity, system, and terminal
operations — re-exported as one umbrella product.

## Overview

`ISO 9945 Kernel` composes the package's per-domain targets into a
single import:

- **File** — descriptors, open/close, read/write, seek, attributes,
  links, permissions, I/O vectors.
- **Directory** — create/remove, working directory, stream iteration.
- **Socket** — addresses, options, send/receive, connect/bind/listen.
- **Signal** — actions, masks, sending, `siginfo_t` decoding.
- **Process** — identifiers, spawning, wait/status, groups.
- **Thread** — creation, mutexes, condition variables, TLS keys.
- **Lock** — file and record locking.
- **Memory** — mapping, shared memory, allocation granularity.
- **Poll** — `poll(2)`-based readiness notification.
- **Clock** / **Time** — realtime/monotonic/CPU clocks and time values.
- **Environment** — process environment get/set/iteration.
- **Identity** — user, group, and login lookups.
- **System** — page size, processor count, and other `sysconf` facts.
- **Terminal** — `termios` attributes and terminal I/O.

`ISO 9945 Glob` (`glob`/`fnmatch`) and `ISO 9945 Loader`
(`dlopen`/`dlclose`) are sibling products with their own catalogs,
not re-exported here.

## Topics
