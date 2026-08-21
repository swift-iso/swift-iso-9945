public import Clock_Primitives

extension ISO_9945.Kernel.Lock {

    public enum Acquire: Sendable, Equatable {

        case `try`

        case wait

        case deadline(Clock.Continuous.Instant)
    }
}
