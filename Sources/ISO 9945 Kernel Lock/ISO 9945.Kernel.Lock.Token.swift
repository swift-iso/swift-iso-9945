#if canImport(Darwin)
    internal import Darwin
#elseif canImport(Glibc)
    internal import Glibc
#elseif canImport(Musl)
    internal import Musl
#endif

extension ISO_9945.Kernel.Lock {

    public struct Token: ~Copyable, Sendable {

        @usableFromInline internal let descriptor: ISO_9945.Kernel.Descriptor
        @usableFromInline internal let range: ISO_9945.Kernel.Lock.Range
        @usableFromInline internal var isReleased: Bool

        public init(
            descriptor: consuming ISO_9945.Kernel.Descriptor,
            range: ISO_9945.Kernel.Lock.Range = .file,
            kind: ISO_9945.Kernel.Lock.Kind,
            acquire: ISO_9945.Kernel.Lock.Acquire = .wait
        ) throws(ISO_9945.Kernel.Lock.Error) {

            try Self.acquireLock(
                descriptor: descriptor,
                range: range,
                kind: kind,
                acquire: acquire
            )

            self.descriptor = descriptor
            self.range = range
            self.isReleased = false
        }

        deinit {

            guard !isReleased else { return }
            do throws(ISO_9945.Kernel.Lock.Error) {
                try ISO_9945.Kernel.Lock.unlock(descriptor, range: range)
            } catch {}
        }
    }
}

extension ISO_9945.Kernel.Lock.Token {

    public mutating func release() throws(ISO_9945.Kernel.Lock.Error) {
        guard !isReleased else { return }
        try ISO_9945.Kernel.Lock.unlock(descriptor, range: range)
        isReleased = true
    }
}

extension ISO_9945.Kernel.Lock.Token {

    private static func acquireLock(
        descriptor: borrowing ISO_9945.Kernel.Descriptor,
        range: ISO_9945.Kernel.Lock.Range,
        kind: ISO_9945.Kernel.Lock.Kind,
        acquire: ISO_9945.Kernel.Lock.Acquire
    ) throws(ISO_9945.Kernel.Lock.Error) {
        switch acquire {
        case .try:
            try ISO_9945.Kernel.Lock.Immediate.lock(descriptor, range: range, kind: kind)

        case .wait:
            try ISO_9945.Kernel.Lock.lock(descriptor, range: range, kind: kind)

        case .deadline(let deadline):
            try acquireWithDeadline(
                descriptor: descriptor,
                range: range,
                kind: kind,
                deadline: deadline
            )
        }
    }

    private static func acquireWithDeadline(
        descriptor: borrowing ISO_9945.Kernel.Descriptor,
        range: ISO_9945.Kernel.Lock.Range,
        kind: ISO_9945.Kernel.Lock.Kind,
        deadline: Clock.Continuous.Instant
    ) throws(ISO_9945.Kernel.Lock.Error) {
        var backoff: Duration = .milliseconds(1)
        let maxBackoff: Duration = .milliseconds(100)

        while true {

            let now = Clock.Continuous.now
            if now >= deadline {
                throw .timedOut
            }

            do throws(ISO_9945.Kernel.Lock.Error) {
                try ISO_9945.Kernel.Lock.Immediate.lock(descriptor, range: range, kind: kind)

                if Clock.Continuous.now >= deadline {

                    try ISO_9945.Kernel.Lock.unlock(descriptor, range: range)
                    throw ISO_9945.Kernel.Lock.Error.timedOut
                }
                return
            } catch {
                switch error {
                case .contention:
                    break

                default:
                    throw error
                }
            }

            let remaining = deadline - Clock.Continuous.now
            if remaining <= .zero {
                throw .timedOut
            }

            let sleepDuration = min(backoff, remaining)
            sleep(sleepDuration)

            backoff = min(backoff * 2, maxBackoff)
        }
    }

    private static func sleep(_ duration: Duration) {
        let (seconds, attoseconds) = duration.components
        let nanoseconds = UInt64(seconds) * 1_000_000_000 + UInt64(attoseconds) / 1_000_000_000

        var ts = timespec()
        ts.tv_sec = Int(nanoseconds / 1_000_000_000)
        ts.tv_nsec = Int(nanoseconds % 1_000_000_000)
        unsafe nanosleep(&ts, nil)
    }
}

extension ISO_9945.Kernel.Lock {

    public static func withExclusive<T, E: Swift.Error>(
        _ descriptor: consuming ISO_9945.Kernel.Descriptor,
        range: ISO_9945.Kernel.Lock.Range = .file,
        acquire: ISO_9945.Kernel.Lock.Acquire = .wait,
        _ body: () throws(E) -> T
    ) throws(ISO_9945.Kernel.Lock.Scope.Error<E>) -> T {
        var token: Token
        do throws(ISO_9945.Kernel.Lock.Error) {
            token = try Token(
                descriptor: consume descriptor,
                range: range,
                kind: .exclusive,
                acquire: acquire
            )
        } catch {
            throw .lock(error)
        }

        defer {
            do throws(ISO_9945.Kernel.Lock.Error) {
                try token.release()
            } catch {}
        }
        do throws(E) {
            return try body()
        } catch {
            throw .body(error)
        }
    }

    public static func withShared<T, E: Swift.Error>(
        _ descriptor: consuming ISO_9945.Kernel.Descriptor,
        range: ISO_9945.Kernel.Lock.Range = .file,
        acquire: ISO_9945.Kernel.Lock.Acquire = .wait,
        _ body: () throws(E) -> T
    ) throws(ISO_9945.Kernel.Lock.Scope.Error<E>) -> T {
        var token: Token
        do throws(ISO_9945.Kernel.Lock.Error) {
            token = try Token(
                descriptor: consume descriptor,
                range: range,
                kind: .shared,
                acquire: acquire
            )
        } catch {
            throw .lock(error)
        }
        defer {
            do throws(ISO_9945.Kernel.Lock.Error) {
                try token.release()
            } catch {}
        }
        do throws(E) {
            return try body()
        } catch {
            throw .body(error)
        }
    }
}
