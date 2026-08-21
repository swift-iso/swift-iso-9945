#if !os(Windows)

    extension Clock.Continuous: _Concurrency.Clock {

        public var now: Instant { Clock.Continuous.now }

        nonisolated(nonsending)
            public func sleep(
                until deadline: Instant,
                tolerance: Duration? = nil
            ) async throws(CancellationError)
        {
            while true {
                let remaining = deadline - Clock.Continuous.now
                guard remaining > .zero else { return }
                do {
                    try Task.checkCancellation()
                    try await Task.sleep(for: remaining, tolerance: tolerance)
                } catch is CancellationError {
                    throw CancellationError()
                } catch {
                    preconditionFailure(
                        "Task.sleep/checkCancellation contract violation: \(type(of: error))"
                    )
                }
            }
        }
    }

    extension Clock.Suspending: _Concurrency.Clock {

        public var now: Instant { Clock.Suspending.now }

        nonisolated(nonsending)
            public func sleep(
                until deadline: Instant,
                tolerance: Duration? = nil
            ) async throws(CancellationError)
        {
            while true {
                let remaining = deadline - Clock.Suspending.now
                guard remaining > .zero else { return }
                do {
                    try Task.checkCancellation()
                    try await Task.sleep(for: remaining, tolerance: tolerance)
                } catch is CancellationError {
                    throw CancellationError()
                } catch {
                    preconditionFailure(
                        "Task.sleep/checkCancellation contract violation: \(type(of: error))"
                    )
                }
            }
        }
    }

#endif
