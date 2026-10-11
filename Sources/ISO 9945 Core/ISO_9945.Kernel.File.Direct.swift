extension ISO_9945.Kernel.File {
    public enum Direct {}
}

extension ISO_9945.Kernel.File.Direct {

    public static func requirements(
        for path: borrowing Path
    ) -> Requirements {
        #if os(macOS)
            return .unknown(reason: .platformUnsupported)
        #elseif os(Linux)
            return .unknown(reason: .sectorSizeUndetermined)
        #elseif os(Windows)
            return .known(Requirements.Alignment(uniform: .`4096`))
        #else
            return .unknown(reason: .platformUnsupported)
        #endif
    }
}

extension ISO_9945.Kernel.File.Direct.Requirements {

    public init(
        bufferAlignment: Memory.Alignment,
        offsetAlignment: Memory.Alignment,
        lengthMultiple: Memory.Alignment
    ) {
        self = .known(
            Alignment(
                bufferAlignment: bufferAlignment,
                offsetAlignment: offsetAlignment,
                lengthMultiple: lengthMultiple
            )
        )
    }

    public init(uniformAlignment alignment: Memory.Alignment) {
        self = .known(Alignment(uniform: alignment))
    }
}
