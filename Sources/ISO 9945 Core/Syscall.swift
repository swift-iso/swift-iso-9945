public enum Syscall {}

extension Syscall {

    @discardableResult
    @inlinable
    public static func require<E: Swift::Error, T>(
        _ value: T,
        _ rule: Rule<T>,
        orThrow makeError: @autoclosure () -> E
    ) throws(E) -> T {
        guard rule.check(value) else { throw makeError() }
        return value
    }
}
