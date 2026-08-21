public enum Syscall {}

extension Syscall {

    public struct Rule<T>: Sendable {
        @usableFromInline
        internal let check: @Sendable (T) -> Bool

        @inlinable
        public init(_ check: @escaping @Sendable (T) -> Bool) {
            self.check = check
        }
    }
}

extension Syscall {

    @discardableResult
    @inlinable
    public static func require<E: Swift.Error, T>(
        _ value: T,
        _ rule: Rule<T>,
        orThrow makeError: @autoclosure () -> E
    ) throws(E) -> T {
        guard rule.check(value) else { throw makeError() }
        return value
    }
}

extension Syscall.Rule where T == Int {

    public static var nonNegative: Self { .init { $0 >= 0 } }
}

extension Syscall.Rule where T: Equatable & Sendable {

    @inlinable
    public static func equals(_ expected: T) -> Self {
        .init { $0 == expected }
    }

    @inlinable
    public static func not(_ value: T) -> Self {
        .init { $0 != value }
    }
}

extension Syscall.Rule where T == Bool {

    public static var isTrue: Self { .init { $0 } }
}

extension Syscall.Rule {

    @inlinable
    public static func notNil<U>() -> Syscall.Rule<U?> {
        .init { $0 != nil }
    }
}
