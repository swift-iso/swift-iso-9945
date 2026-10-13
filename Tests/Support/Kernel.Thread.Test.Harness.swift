import Error
import ISO_9945_Kernel
import Path

public enum KernelThreadTest {

    public struct Timeout: Swift::Error, Sendable, Equatable {
        public init() {}
    }

    public final class Harness<State: Sendable>: @unchecked Sendable {
        private let mutex: ISO_9945.Kernel.Thread.Mutex
        private let condition: ISO_9945.Kernel.Thread.Condition
        private var state: State
        private let limit: Swift::Duration

        public convenience init(_ initial: State) {
            self.init(initial, limit: .seconds(10))
        }

        package init(_ initial: State, limit: Swift::Duration) {
            self.mutex = ISO_9945.Kernel.Thread.Mutex()
            self.condition = ISO_9945.Kernel.Thread.Condition()
            self.state = initial
            self.limit = limit
        }

        public func update(_ body: (inout State) -> Void) {
            mutex.lock()
            body(&state)
            condition.broadcast()
            mutex.unlock()
        }

        public func wait(until predicate: (State) -> Bool) throws(Timeout) {
            mutex.lock()
            defer { mutex.unlock() }

            let clock = Swift::ContinuousClock()
            let deadline = clock.now.advanced(by: limit)
            while !predicate(state) {
                let remaining = clock.now.duration(to: deadline)
                guard remaining > .zero else { throw Timeout() }
                _ = condition.wait(mutex: mutex, timeout: remaining)
            }
        }

        public func withLocked<R>(_ body: (State) -> R) -> R {
            mutex.lock()
            defer { mutex.unlock() }
            return body(state)
        }
    }
}
