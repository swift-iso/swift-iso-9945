internal import ISO_9945_Shims

extension ISO_9945.Glob {

    public enum Fnmatch: Sendable {}
}

extension ISO_9945.Glob {

    public static func fnmatch(
        pattern: borrowing Path.Borrowed,
        name: borrowing Path.Borrowed,
        options: Fnmatch.Options = []
    ) throws(Fnmatch.Error) -> Bool {
        let result = unsafe iso9945_fnmatch(
            UnsafeRawPointer(pattern.pointer).assumingMemoryBound(to: CChar.self),
            UnsafeRawPointer(name.pointer).assumingMemoryBound(to: CChar.self),
            options.rawValue
        )
        if result == 0 { return true }
        if result == iso9945_fnm_nomatch() { return false }
        throw ISO_9945.Glob.Fnmatch.Error.failed(code: result)
    }
}
