import Error
import ISO_9945_Kernel
import Path

public final class LockedBox<T>: @unchecked Sendable {
    private var value: T
    private let lock: ISO_9945.Kernel.Thread.Mutex

    public init(_ initial: T) {
        self.value = initial
        self.lock = .init()
    }

    public func withLock<R>(_ body: (inout T) throws -> R) rethrows -> R {
        lock.lock()
        defer { lock.unlock() }
        return try body(&value)
    }
}

public final class Gate: @unchecked Sendable {
    private let mutex: ISO_9945.Kernel.Thread.Mutex
    private let condition: ISO_9945.Kernel.Thread.Condition
    private var isOpen: Bool

    public init(open: Bool = false) {
        self.mutex = .init()
        self.condition = .init()
        self.isOpen = open
    }

    public func open() {
        mutex.lock()
        isOpen = true
        condition.broadcast()
        mutex.unlock()
    }

    public func wait() {
        mutex.lock()
        while !isOpen {
            condition.wait(mutex: mutex)
        }
        mutex.unlock()
    }
}

public final class Signal: @unchecked Sendable {
    private let mutex: ISO_9945.Kernel.Thread.Mutex
    private let condition: ISO_9945.Kernel.Thread.Condition
    private var signaled: Bool

    public init() {
        self.mutex = .init()
        self.condition = .init()
        self.signaled = false
    }

    public func signal() {
        mutex.lock()
        signaled = true
        condition.broadcast()
        mutex.unlock()
    }

    public func wait() {
        mutex.lock()
        while !signaled {
            condition.wait(mutex: mutex)
        }
        mutex.unlock()
    }
}
