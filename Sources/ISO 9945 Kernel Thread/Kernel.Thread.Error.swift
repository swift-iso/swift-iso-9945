extension ISO_9945.Kernel.Thread {

    public enum Error: Swift.Error, Sendable, Equatable, Hashable {

        case create(Error_Primitives.Error.Code)

        case join(Error_Primitives.Error.Code)

        case detach(Error_Primitives.Error.Code)

        case keyCreate(Error_Primitives.Error.Code)

        case keySet(Error_Primitives.Error.Code)
    }
}

extension ISO_9945.Kernel.Thread.Error: CustomStringConvertible {
    public var description: Swift.String {
        switch self {
        case .create(let code):
            return "Thread creation failed: \(code)"

        case .join(let code):
            return "Thread join failed: \(code)"

        case .detach(let code):
            return "Thread detach failed: \(code)"

        case .keyCreate(let code):
            return "Thread-local storage key creation failed: \(code)"

        case .keySet(let code):
            return "Thread-local storage slot write failed: \(code)"
        }
    }
}
