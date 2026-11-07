public import Binary

extension ISO_9945 {

    /// A filename (IEEE 1003.1-2024 §3.170): a non-empty name with neither `/` nor NUL.
    ///
    /// Stored inline in ``Path/Small``, which holds `NAME_MAX` (255 bytes) without allocating.
    /// Text is held to more: it may not contain control characters either. A name the system hands
    /// back may; build those from their code units with ``init(platformNative:)``.
    @frozen
    public struct Filename: Hashable, Sendable {

        @usableFromInline
        internal var _units: Path.Small<256>

        @inlinable
        internal init(_units units: Path.Small<256>) {
            self._units = units
        }
    }
}

extension Path {

    /// One component of a path: on POSIX, a ``ISO_9945/Filename``.
    public typealias Component = ISO_9945.Filename
}

extension ISO_9945.Filename {

    /// The separator a filename may not contain.
    public static var separator: Path.Char { 0x2F }

}

extension ISO_9945.Filename.Error: CustomStringConvertible {

    public var description: Swift::String {
        switch self {
        case .empty: return "Component is empty"
        case .containsPathSeparator: return "Component contains path separator"
        case .containsControlCharacters: return "Component contains control characters"
        case .containsInteriorNUL: return "Component contains interior NUL byte"
        case .invalidUTF8: return "Component contains invalid UTF-8"
        }
    }
}

extension ISO_9945.Filename {

    /// The filename `string` spells.
    @inlinable
    public init(_ string: Swift::String) throws(Error) {
        guard !string.isEmpty else { throw .empty }
        for scalar in string.unicodeScalars {
            if scalar.value == 0 { throw .containsInteriorNUL }
            if scalar == "/" { throw .containsPathSeparator }
            if scalar.value < 0x20 || scalar.value == 0x7F { throw .containsControlCharacters }
        }
        do throws(Path.Error) {
            self.init(_units: try Path.Small<256>(validating: string))
        } catch {
            preconditionFailure("text already checked: \(error)")
        }
    }

    /// The filename a directory entry names, from its code units. The units must be valid UTF-8 and
    /// hold to the rules for text.
    @inlinable
    public init(platformNative codeUnits: [Path.Char]) throws(Error) {
        guard let string = Swift::String(validating: codeUnits, as: UTF8.self) else {
            throw .invalidUTF8
        }
        try self.init(string)
    }

    /// Code units already known to form a filename: non-empty, no `/`, no NUL.
    @inlinable
    public init(unchecked units: Swift::Span<Path.Char>) {
        self.init(_units: Path.Small<256>(units))
    }

    /// Text already known to form a filename.
    @inlinable
    public init(unchecked string: Swift::String) {
        do throws(Path.Error) {
            self.init(_units: try Path.Small<256>(validating: string))
        } catch {
            preconditionFailure("not a filename: \(string) (\(error))")
        }
    }
}

extension ISO_9945.Filename {

    /// The name as text.
    @inlinable
    public var string: Swift::String { _units.string }

    /// The number of code units.
    @inlinable
    public var count: Int { _units.count }

    /// The code units and their NUL, lent to a system call.
    @inlinable
    public var view: Path.Borrowed {
        @_lifetime(borrow self) borrowing get {
            let pointer = unsafe _units.view.pointer
            let view = unsafe Path.Borrowed(pointer, count: _units.count)
            return unsafe _overrideLifetime(view, borrowing: self)
        }
    }
}

extension Swift::String {

    /// The text of `filename`.
    @inlinable
    public init(_ filename: ISO_9945.Filename) {
        self = filename.string
    }
}

extension ISO_9945.Filename: CustomStringConvertible, CustomDebugStringConvertible {

    public var description: Swift::String { string }

    public var debugDescription: Swift::String { "Path.Component(\"\(string)\")" }
}

extension ISO_9945.Filename: ExpressibleByStringLiteral {

    @inlinable
    public init(stringLiteral value: Swift::String) {
        do {
            try self.init(value)
        } catch {
            fatalError("Invalid path component literal: \(value) (\(error))")
        }
    }
}

/// Interpolated text is a filename by the same rule as a plain literal.
extension ISO_9945.Filename: ExpressibleByStringInterpolation {}

extension ISO_9945.Filename: Binary.Serializable {

    /// The name's text, as UTF-8.
    @inlinable
    public static func serialize<Buffer: RangeReplaceableCollection>(
        _ filename: borrowing Self,
        into buffer: inout Buffer
    ) where Buffer.Element == Byte {
        buffer.append(contentsOf: filename.string.utf8.map(Byte.init(bitPattern:)))
    }
}
