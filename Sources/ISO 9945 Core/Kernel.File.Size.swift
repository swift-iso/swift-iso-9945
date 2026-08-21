public import Binary_Primitives

extension ISO_9945.Kernel.File {

    public typealias Size = Magnitude<Space>.Value<Int64>
}

extension ISO_9945.Kernel.File.Size {

    public static let kilobyte: Self = Self(1024)

    public static let megabyte: Self = Self(1024 * 1024)

    public static let gigabyte: Self = Self(1024 * 1024 * 1024)

    @inlinable
    public static func page(size pageSize: UInt) -> Self {
        Self(Int64(pageSize))
    }
}

extension ISO_9945.Kernel.File.Size {

    @inlinable
    public init(pages: Int, pageSize: UInt) {
        self.init(Int64(pages) * Int64(pageSize))
    }

    @inlinable
    public init(_ value: Int) {
        self.init(Int64(value))
    }

    @inlinable
    public init(_ value: UInt64) {
        precondition(
            value <= UInt64(Int64.max),
            "File.Size cannot represent \(value); it exceeds Int64.max"
        )
        self.init(Int64(value))
    }

    @inlinable
    public init(_ delta: ISO_9945.Kernel.File.Delta) {
        precondition(delta.underlying >= 0, "Delta must be non-negative to convert to Size")
        self.init(delta.underlying)
    }
}

extension ISO_9945.Kernel.File.Size {

    @inlinable
    public var isZero: Bool {
        underlying == 0
    }

    @inlinable
    public var isPositive: Bool {
        underlying > 0
    }
}

extension ISO_9945.Kernel.File.Size {

    public func isAligned(to alignment: Memory.Alignment) -> Bool {
        let mask: Int64 = alignment.mask()
        return underlying & mask == 0
    }

    public func alignedDown(to alignment: Memory.Alignment) -> Self {
        let mask: Int64 = alignment.mask()
        return Self(underlying & ~mask)
    }

    public func alignedUp(to alignment: Memory.Alignment) -> Self {
        let mask: Int64 = alignment.mask()
        return Self((underlying &+ mask) & ~mask)
    }
}

extension Int {

    @inlinable
    public init(_ size: ISO_9945.Kernel.File.Size) {
        self = Int(size.underlying)
    }
}
