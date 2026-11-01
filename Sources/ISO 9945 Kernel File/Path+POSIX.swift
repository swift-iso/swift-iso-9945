// The POSIX pathname grammar (IEEE 1003.1-2024 §3.254, §4.16): `/` separates components, and a
// pathname that begins with `/` is absolute. Written once on `Path.Protocol`, so it reaches every
// store. The scans read `view` inline: see `Path.Protocol` on why it is not bound to a local.

extension Path.`Protocol` where Self: ~Copyable {

    /// The pathname `string` spells. POSIX gives `/` no rewriting: the code units are the text's.
    ///
    /// Text may not be empty or contain NUL or control characters; see `init(validating:)`.
    @inlinable
    public init(_ string: Swift::String) throws(Path.Error) {
        try self.init(validating: string)
    }
}

extension Path: @retroactive ExpressibleByStringLiteral {

    @inlinable
    public init(stringLiteral value: Swift::String) {
        do throws(Path.Error) {
            try self.init(value)
        } catch {
            fatalError("Invalid path literal: \(value) (\(error))")
        }
    }
}

extension Path.`Protocol` where Self: ~Copyable {

    /// Whether the path begins at the root.
    @inlinable
    public var isAbsolute: Bool {
        unsafe view.count > 0 && view.pointer[0] == ISO_9945.Filename.separator
    }

    /// Whether the path is resolved against a working directory.
    @inlinable
    public var isRelative: Bool { !isAbsolute }

    /// Whether the path is the root, `/`.
    @inlinable
    public var isRoot: Bool {
        unsafe view.count == 1 && view.pointer[0] == ISO_9945.Filename.separator
    }

    /// Whether the last code unit is a separator.
    @inlinable
    public var endsWithSeparator: Bool {
        unsafe view.count > 0 && view.pointer[view.count - 1] == ISO_9945.Filename.separator
    }
}

extension Path.`Protocol` where Self: ~Copyable {

    /// The path without its last component: `nil` for the root and for a single relative component,
    /// and `/` for a component directly under the root.
    @inlinable
    public var parent: Self? {
        guard let separator = _lastSeparator(before: view.count) else { return nil }
        if separator == 0 {
            if view.count == 1 { return nil }
            return prefix(1)
        }
        return prefix(separator)
    }

    /// The last component, or `nil` when the path has none (the root).
    @inlinable
    public var lastComponent: Path.Component? {
        let end = _lastNonSeparator(before: view.count)
        guard end > 0 else { return nil }
        let start = _lastSeparator(before: end).map { $0 + 1 } ?? 0
        let span = unsafe Swift::Span<Path.Char>(_unsafeStart: view.pointer + start, count: end - start)
        return Path.Component(unchecked: span)
    }

    /// The path with `component` after it, joined by one separator.
    @inlinable
    public borrowing func appending(_ component: Path.Component) -> Self {
        Self.joining(
            view,
            separator: endsWithSeparator ? nil : ISO_9945.Filename.separator,
            component.view
        )
    }

    /// The path with the component that `string` spells after it.
    @inlinable
    public borrowing func appending(_ string: Swift::String) throws(Path.Component.Error) -> Self {
        appending(try Path.Component(string))
    }

    /// `other` resolved against this path: `other` itself when it is absolute, otherwise both joined
    /// by one separator.
    @inlinable
    public borrowing func appending<Other: Path.`Protocol` & ~Copyable>(_ other: borrowing Other) -> Self {
        if other.isAbsolute {
            return Self(copying: other.view)
        }
        return Self.joining(
            view,
            separator: endsWithSeparator ? nil : ISO_9945.Filename.separator,
            other.view
        )
    }
}

extension Path.`Protocol` where Self: ~Copyable {

    /// The components, without separators.
    @inlinable
    public var components: Path.Components {
        Path.Components(Path(copying: view))
    }

    /// Whether `other`'s components begin this path's, and both are absolute or both relative.
    @inlinable
    public borrowing func hasPrefix<Other: Path.`Protocol` & ~Copyable>(_ other: borrowing Other) -> Bool {
        guard isAbsolute == other.isAbsolute else { return false }
        var mine = components.makeIterator()
        var theirs = other.components.makeIterator()
        while let component = theirs.next() {
            guard let own = mine.next(), own == component else { return false }
        }
        return true
    }

    /// This path relative to `base`: `nil` unless `base` is a prefix of it, and `.` when both are the
    /// same.
    @inlinable
    public borrowing func relative<Other: Path.`Protocol` & ~Copyable>(to base: borrowing Other) -> Self? {
        guard isAbsolute == base.isAbsolute else { return nil }
        let own = components
        var index = own.startIndex
        var theirs = base.components.makeIterator()
        while let component = theirs.next() {
            guard index != own.endIndex, own[index] == component else { return nil }
            index = own.index(after: index)
        }
        guard index != own.endIndex else {
            let dot: [Path.Char] = [0x2E]
            return Self(dot.span)
        }
        let path = own.path
        let start = index
        let count = path._lastNonSeparator(before: path.count) - start
        return unsafe Self(count: count) { base in
            unsafe base.initialize(from: path.view.pointer + start, count: count)
        }
    }
}

extension Path.`Protocol` {

    /// `lhs` with `rhs` after it.
    @inlinable
    public static func / (lhs: Self, rhs: Path.Component) -> Self {
        lhs.appending(rhs)
    }

    /// `rhs` resolved against `lhs`.
    @_disfavoredOverload
    @inlinable
    public static func / (lhs: Self, rhs: Self) -> Self {
        lhs.appending(rhs)
    }
}

extension Path.`Protocol` where Self: ~Copyable {

    @inlinable
    package borrowing func _isSeparator(at index: Int) -> Bool {
        unsafe view.pointer[index] == ISO_9945.Filename.separator
    }

    @inlinable
    package borrowing func _firstSeparator(from start: Int) -> Int? {
        var index = start
        while index < view.count {
            if _isSeparator(at: index) { return index }
            index += 1
        }
        return nil
    }

    @inlinable
    package borrowing func _firstNonSeparator(from start: Int) -> Int {
        var index = start
        while index < view.count {
            if !_isSeparator(at: index) { return index }
            index += 1
        }
        return view.count
    }

    @inlinable
    package borrowing func _lastSeparator(before end: Int) -> Int? {
        var index = end - 1
        while index >= 0 {
            if _isSeparator(at: index) { return index }
            index -= 1
        }
        return nil
    }

    /// The end of the last component that ends at or before `end`: the index after its last unit.
    @inlinable
    package borrowing func _lastNonSeparator(before end: Int) -> Int {
        var index = end - 1
        while index >= 0 {
            if !_isSeparator(at: index) { return index + 1 }
            index -= 1
        }
        return 0
    }
}

extension Path {

    /// A path's components, in order, without separators.
    public struct Components: BidirectionalCollection, Sendable {

        @usableFromInline
        package let path: Path

        @inlinable
        package init(_ path: Path) {
            self.path = path
        }
    }
}

extension Path.Components {

    public typealias Element = Path.Component

    public typealias Index = Int

    @inlinable
    public var startIndex: Int { path._firstNonSeparator(from: 0) }

    @inlinable
    public var endIndex: Int { path.count }

    @inlinable
    public subscript(position: Int) -> Path.Component {
        let end = path._firstSeparator(from: position) ?? endIndex
        return Path.Component(unchecked: path.content.extracting(position..<end))
    }

    @inlinable
    public func index(after index: Int) -> Int {
        let end = path._firstSeparator(from: index) ?? endIndex
        return path._firstNonSeparator(from: end)
    }

    @inlinable
    public func index(before index: Int) -> Int {
        let end = path._lastNonSeparator(before: index)
        return path._lastSeparator(before: end).map { $0 + 1 } ?? 0
    }
}
