#if canImport(Darwin)
    internal import Darwin
#elseif canImport(Glibc)
    internal import Glibc
#elseif canImport(Musl)
    internal import Musl
#endif

extension ISO_9945.Glob {

    public enum Expand: Sendable {}
}

extension ISO_9945.Glob {

    public static func expand(
        pattern: borrowing Path.Borrowed,
        options: Expand.Options = []
    ) throws(Expand.Error) -> [Swift.String] {
        var gt = unsafe glob_t()

        let result = unsafe glob(
            UnsafeRawPointer(pattern.pointer).assumingMemoryBound(to: CChar.self),
            options.rawValue,
            nil,
            &gt
        )
        defer { unsafe globfree(&gt) }

        switch result {
        case 0:
            var paths: [Swift.String] = []
            let count = unsafe Int(gt.gl_pathc)
            paths.reserveCapacity(count)

            for i in 0..<count {
                if let cPath = unsafe gt.gl_pathv[i] {
                    paths.append(unsafe Swift.String(cString: cPath))
                }
            }
            return paths

        case GLOB_NOMATCH:
            throw .noMatch

        case GLOB_NOSPACE:
            throw .noSpace

        case GLOB_ABORTED:
            throw .aborted

        default:
            throw .unrecognized(code: result)
        }
    }
}
