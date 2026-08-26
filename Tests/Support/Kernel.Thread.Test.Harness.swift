import Error
import ISO_9945_Kernel
import Path

public enum KernelThreadTest {

    public struct Timeout: Swift.Error, Sendable, Equatable {
        public init() {}
    }

    public final class Harness<State: Sendable>: @unchecked Sendable {
        private let mutex: ISO_9945.Kernel.Thread.Mutex
        private let condition: ISO_9945.Kernel.Thread.Condition
        private var state: State

        public init(_ initial: State) {
            self.mutex = ISO_9945.Kernel.Thread.Mutex()
            self.condition = ISO_9945.Kernel.Thread.Condition()
            self.state = initial
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

            while !predicate(state) {
                condition.wait(mutex: mutex)
            }
        }

        public func withLocked<R>(_ body: (State) -> R) -> R {
            mutex.lock()
            defer { mutex.unlock() }
            return body(state)
        }
    }
}
